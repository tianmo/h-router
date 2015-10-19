e      = require 'expect.js'
Router = require '../lib'

request = (url)->
  @url = url

response = ->
response.prototype.end = ->

describe 'router', ->
  it 'use fn', (done)->
    app = Router()
    app.registFunc (req, res, next)=>
      e(req.query).to.eql name : 'test'
      done()
    app.use (req, res, next)=>
      req.query = name : 'test'
      next()
    mw = app.handle()
    req = new request '/api'
    res = new response
    setTimeout ->
      mw req, res

  it 'use router', (done)->
    app = Router()
    app.registFunc (req, res, next)=>
      e().fail 'should not exec'
    app.registFunc '/api/test', (req, res, next)=>
      e(req.query).to.eql name : 'test'
      done()
    app.use '/api', (req, res, next)=>
      req.query = name : 'test'
      next()
    mw = app.handle()
    req = new request '/api/test'
    res = new response
    setTimeout ->
      mw req, res

  it 'regist rest url', (done)->
    app = Router()
    app.registFunc (req, res, next)=>
      e().fail 'should not exec'
    app.registFunc '/api/test', (req, res, next)=>
      e(req.query).to.eql name : 'test'
      done()
    app.use '/api', (req, res, next)=>
      req.query = name : 'test'
      next()
    mw = app.handle()
    req = new request '/api/test/tt'
    res = new response
    setTimeout ->
      mw req, res

  it 'multiple', (done)->
    app = Router()
    app.registFunc (req, res, next)=>
      e().fail 'should not exec'
    app.registFunc '/api/test', (req, res, next)=>
      e().fail 'should not exec'
      res.end()
    app.registFunc '/api/route', (req, res, next)=>
      e(req.query.join ' ').to.be 'root api route'
      res.end()
    app.registFunc '/api/route1', (req, res, next)=>
      e().fail 'should not exec'
      res.end()
    app.registFunc '/api/route/r1/r2/r3', (req, res, next)=>
      e().fail 'should not exec'
      res.end()
    app.use (req, res, next)=>
      req.query = ['root']
      next()
    app.use '/api', (req, res, next)=>
      req.query.push 'api'
      next()
    app.use '/api/route', (req, res, next)=>
      req.query.push 'route'
      next()
    app.use '/api/route1', (req, res, next)=>
      req.query.push 'route1'
      e().fail 'should not exec'
      next()
    app.use '/api/route/r1/r2', (req, res, next)=>
      req.query.push 'r1 r2'
      e().fail 'should not exec'
      next()
    mw = app.handle()
    req = new request '/api/route/r1/r2'
    res = new response
    mw req, res
    done()

  it 'url with param', (done)->
    app = Router()
    app.registFunc (req, res, next)=>
      e().fail 'should not exec'
    app.registFunc '/api/test', (req, res, next)=>
      e(req.query).to.eql name : 'test'
      e(req.url).to.be '/tt'
      e(req.originalUrl).to.be '/api/test/tt?par1=test&par2=t'
      done()
    app.use '/api', (req, res, next)=>
      req.query = name : 'test'
      next()
    mw = app.handle()
    req = new request '/api/test/tt?par1=test&par2=t'
    res = new response
    setTimeout ->
      mw req, res

  it 'root url', (done)->
    app = Router()
    app.registFunc (req, res, next)=>
      e(req.url).to.be ''
      e(req.originalUrl).to.be '/'
      done()
    app.registFunc '/api/test', (req, res, next)=>
      e().fail 'should not exec'
    app.use '/api', (req, res, next)=>
      e().fail 'should not exec'
    mw = app.handle()
    req = new request '/'
    res = new response
    setTimeout ->
      mw req, res

  it 'rest url', (done)->
    app = Router()
    app.registFunc '/api/test', (req, res, next)=>
      e(req.url).to.be '/name'
      e(req.originalUrl).to.be '/api/test/name'
      done()
    app.use '/api', (req, res, next)=>
      req.query = name : 'test'
      next()
    mw = app.handle()
    req = new request '/api/test/name'
    res = new response
    setTimeout ->
      mw req, res

  it 'exec with no end', (done)->
    app = Router()
    app.registFunc '/api/test', (req, res, next)=>
      e(req.url).to.be '/name'
      e(req.originalUrl).to.be '/api/test/name'
      next()
    app.use '/api', (req, res, next)=>
      req.query = name : 'test'
      next()
    mw = app.handle()
    req = new request '/api/test/name'
    res = new response
    res.end = (msg)->
      e(msg).to.be '/api/test/name not found'
    mw req, res
    setTimeout ->
      done()

  it 'send on header send', (done)->
    app = Router()
    app.registFunc '/api/test', (req, res, next)=>
      e().fail 'should not exec'
    app.use '/api', (req, res, next)=>
      res.end()
      next()
    mw = app.handle()
    req = new request '/api/test/name'
    res = new response
    res.end = ->
      res.headersSent = true
    mw req, res
    setTimeout ->
      done()

  it 're-regist Func', (done)->
    app = Router()
    app.registFunc '/fine', (req, res, next)=>
      res.end()
    app.registFunc '/api', (req, res, next)=>
      e().fail 'should not exec'
      res.end()
    app.use '/api', (req, res, next)=>
      e().fail 'should not exec'
      next()
    app.registFunc '/api', (req, res, next)=>
      res.end()
    app.use '/api', (req, res, next)=>
      next()
    mw = app.handle()
    req = new request '/fine'
    res = new response
    res.end = ->
      req = new request '/api'
      res = new response
      res.end = ->
        done()
        res.headersSent = true
      mw req, res
    mw req, res

describe 'compile buffer', ->
  it 'not found', (done)->
    app = Router compileBuffer : true
    app.registFunc (req, res, next)=>
      e().fail 'should not exec'
    app.registFunc '/api/test', (req, res, next)=>
      e().fail 'should not exec'
      res.end()
    app.registFunc '/api/route', (req, res, next)=>
      e(req.query.join ' ').to.be 'root api route'
      res.end()
    app.registFunc '/api/route1', (req, res, next)=>
      e().fail 'should not exec'
      res.end()
    app.registFunc '/api/route/r1/r2/r3', (req, res, next)=>
      e().fail 'should not exec'
      res.end()
    app.use (req, res, next)=>
      req.query = ['root']
      next()
    app.use '/api', (req, res, next)=>
      req.query.push 'api'
      next()
    app.use '/api/route', (req, res, next)=>
      req.query.push 'route'
      next()
    app.use '/api/route1', (req, res, next)=>
      req.query.push 'route1'
      e().fail 'should not exec'
      next()
    app.use '/api/route/r1/r2', (req, res, next)=>
      req.query.push 'r1 r2'
      e().fail 'should not exec'
      next()
    mw = app.handle()
    req = new request '/api/route/r1/r2'
    res = new response
    res.end = (msg)->
      e(msg).to.be '/api/route/r1/r2 not found'
    mw req, res
    done()

  it 'sucess', (done)->
    app = Router compileBuffer : true
    app.registFunc (req, res, next)=>
      e().fail 'should not exec'
    app.registFunc '/api/test', (req, res, next)=>
      e().fail 'should not exec'
      res.end()
    app.registFunc '/api/route', (req, res, next)=>
      e(req.query.join ' ').to.be 'root api route'
      res.end req.query.join ' '
    app.registFunc '/api/route1', (req, res, next)=>
      e().fail 'should not exec'
      res.end()
    app.registFunc '/api/route/r1/r2/r3', (req, res, next)=>
      e().fail 'should not exec'
      res.end()
    app.use (req, res, next)=>
      req.query = ['root']
      next()
    app.use '/api', (req, res, next)=>
      req.query.push 'api'
      next()
    app.use '/api/route', (req, res, next)=>
      req.query.push 'route'
      next()
    app.use '/api/route1', (req, res, next)=>
      req.query.push 'route1'
      e().fail 'should not exec'
      next()
    app.use '/api/route/r1/r2', (req, res, next)=>
      req.query.push 'r1 r2'
      e().fail 'should not exec'
      next()
    app.compile()
    mw = app.handle()
    req = new request '/api/route/r1/r2'
    res = new response
    res.end = (msg)->
      e(msg).to.be 'root api route'
    mw req, res
    done()
