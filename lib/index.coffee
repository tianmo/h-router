defaultRouter = (req, res)->
  res.statusCode = 404
  res.end "#{req.originalUrl} not found"

class Router
  constructor : (options = {})->
    @stack = []
    @funcs = {}
    @routers = {}
    @defaultRouter = options.defaultRouter or defaultRouter
    @compileBuffer = options.compileBuffer

  use : (route, fn)->
    if 'function' is typeof route
      fn = route
      route = '/'
    @stack.push route : route, handle : fn
    @compile() unless @compileBuffer

  unuse: (route) ->
    newStack = []
    for router,i in @stack when router.route isnt route
      newStack.push router
    @stack = newStack

  registFunc : (route, fn)->
    if 'function' is typeof route
      fn = route
      route = '/'
    @unuse(route)
    @funcs[route] = fn

  unRegist : (route)->
    @unuse route
    delete @funcs[route] if @funcs[route]
    @compile()

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
      router = @defaultRouter unless router
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

module.exports = (options)->
  new Router options
