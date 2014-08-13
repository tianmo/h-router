class Router
  constructor : ->
    @stack = []
    @funcs = {}
    @routers = {}

  use : (route, fn)->
    if 'function' is typeof route
      fn = route
      route = '/'
    @stack.push route : route, handle : fn
    @compile()

  unuse: (route) ->
    for router,i in @stack when router.route is route
      @stack.splice i, 1

  registFunc : (route, fn)->
    if 'function' is typeof route
      fn = route
      route = '/'
    @unuse(route)
    @funcs[route] = fn

  compile : ->
    middlewares = {}
    routers = {}
    for {route, handle} in @stack
      middlewares[route] = [] unless middlewares[route]
      middlewares[route].push handle

    rootHandles = middlewares['/'] or []

    for path, fn of @funcs
      fns = rootHandles
      routes = path.split '/'
      routes.shift()
      parent = ''
      for route in routes
        continue unless route
        parent = "#{parent}/#{route}"
        parentHandles = middlewares[parent]
        continue unless parentHandles
        fns = fns.concat parentHandles
      fns = fns.concat fn
      routers[path] = fns
    @routers = routers

  handle : ->
    (req, res)=>
      url = req.url
      search = 1 + url.indexOf '?'
      pathlength = if search then search - 1 else url.length
      path = url.substr 0, pathlength
      req.originalUrl = url
      routers = @routers[path]
      if routers
        req.url = ''
        @execMws req, res, routers
        return
      @execStack req, res, path

  execMws : (req, res, routers)->
    index = 0
    next = =>
      router = routers[index++]
      return if res.headersSent
      return if !router
      router req, res, next.bind @
    next()

  execStack : (req, res, path)->
    routers = @routers
    routes = path.split '/'
    routes.shift()
    parent = ''
    url = '/'
    stack = routers['/'] or []
    for route in routes
      parent = "#{parent}/#{route}"
      handles = routers[parent]
      if handles
        stack = handles
        url = parent
    req.url = path.substr url.length
    @execMws req, res, stack

module.exports = ->
  new Router
