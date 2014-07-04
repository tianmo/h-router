Router  = require '../lib'
connect = require 'connect'
http    = require 'http'

app = Router()
app.registFunc '/favicon.ico', (req, res, next)->
  res.statusCode = 200
  res.end 'success'

app.registFunc '/', (req, res, next)->
  res.statusCode = 200
  res.end 'success ' + req.params.toString()

app.registFunc '/api/v1/test1', (req, res, next)->
  res.statusCode = 200
  res.end 'test ' + req.params.toString()

app.registFunc '/api/v1/test2', (req, res, next)->
  res.statusCode = 200
  res.end 'test ' + req.params.toString()

app.registFunc '/api/v1/test3', (req, res, next)->
  res.statusCode = 200
  res.end 'test ' + req.params.toString()

app.registFunc '/api/v1/test4', (req, res, next)->
  res.statusCode = 200
  res.end 'test ' + req.params.toString()

app.registFunc '/api/v1/test5', (req, res, next)->
  res.statusCode = 200
  res.end 'test ' + req.params.toString()

app.registFunc '/api/v1/test6', (req, res, next)->
  res.statusCode = 200
  res.end 'test ' + req.params.toString()

app.registFunc '/api/v1/test7', (req, res, next)->
  res.statusCode = 200
  res.end 'test ' + req.params.toString()

for i in [10..100]
  app.registFunc '/api/v1/test' + i, (req, res, next)->
    res.statusCode = 200
    res.end 'test ' + req.params.toString()

app.registFunc '/api/v1/test', (req, res, next)->
  res.statusCode = 200
  res.end 'test ' + req.params.toString()

app.use (req, res, next)=>
  req.params = ['1', '2', '3']
  next()

app.use '/api', (req, res, next)=>
  req.params.push 'api'
  next()

app.use '/api/v1', (req, res, next)=>
  req.params.push 'v1'
  next()

app.use '/api/v1/test', (req, res, next)=>
  req.params.push 'test'
  next()

handle = app.handle()

con = connect()
con.use (req, res, next)=>
  req.params = ['1', '2', '3']
  next()

con.use '/api', (req, res, next)=>
  req.params.push 'api'
  next()

con.use '/api/v1', (req, res, next)=>
  req.params.push 'v1'
  next()

con.use '/api/v1/test', (req, res, next)=>
  req.params.push 'test'
  next()

con.use '/favicon.ico', (req, res, next)->
  res.statusCode = 200
  res.end 'success'

con.use '/api/v1/test1', (req, res, next)->
  res.statusCode = 200
  res.end 'test ' + req.params.toString()

con.use '/api/v1/test2', (req, res, next)->
  res.statusCode = 200
  res.end 'test ' + req.params.toString()

con.use '/api/v1/test3', (req, res, next)->
  res.statusCode = 200
  res.end 'test ' + req.params.toString()

con.use '/api/v1/test4', (req, res, next)->
  res.statusCode = 200
  res.end 'test ' + req.params.toString()

con.use '/api/v1/test5', (req, res, next)->
  res.statusCode = 200
  res.end 'test ' + req.params.toString()

con.use '/api/v1/test6', (req, res, next)->
  res.statusCode = 200
  res.end 'test ' + req.params.toString()

con.use '/api/v1/test7', (req, res, next)->
  res.statusCode = 200
  res.end 'test ' + req.params.toString()

for i in [10..100]
  con.use '/api/v1/test' + i, (req, res, next)->
    res.statusCode = 200
    res.end 'test ' + req.params.toString()

con.use '/api/v1/test', (req, res, next)->
  res.statusCode = 200
  res.end 'test ' + req.params.toString()

con.use '/', (req, res, next)->
  res.statusCode = 200
  res.end 'success ' + req.params.toString()

len = 10000

res =
  end : (msg)->

console.time 't1'
for i in [0...len]
  handle url : '/api/v1/test', res
console.timeEnd 't1'

console.time 't2'
for i in [0...len]
  handle url : '/api/v1/test/name/value/key/ali', res
console.timeEnd 't2'

console.time 't3'
for i in [0...len]
  con.handle url : '/api/v1/test', res
console.timeEnd 't3'

