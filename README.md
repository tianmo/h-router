h-router
========

高性能的router

```coffeescript
http    = require 'http'
router  = require 'h-router'

app  = router()
http = http.createServer app.handle()

app.registFunc '/', (req, res, next)->
  res.statusCode = 200
  res.end 'success'

app.registFunc '/route', (req, res, next)->
  res.statusCode = 200
  res.end 'route'

app.use (req, res, next)->
  req.query = name : 'name'
  next()

app.use '/route', (req, res, next)->
  req.routeParam = []
  next()

app.use '/route/error', (req, res, next)->
  res.end 'error'

```

router会按照use的middleware顺序执行，最后执行registFunc的方法

如：/route/name/type/args

则按顺序执行 /、/route、/route/name、/route/name/type、/route/name/type/args路由上use的middleware，最后再执行/route/name/type/args的registFunc的方法，如果没有注册，则按照url依次前推，知道找到对应的方法。

### 性能

* 使用h-router注册/api/v1/test的路由，其他不同路径的路由各注册约100个
  * t1：发送完全匹配的url：/api/v1/test
  * t2：发送有后缀的url：/api/v1/test/name/value/key/ali
* t3：使用connect注册相同的路由，发送url：/api/v1/test

以上三个请求各执行10000次的结果

```
t1: 168ms
t2: 231ms
t3: 486ms
```

