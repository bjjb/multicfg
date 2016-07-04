# multicfg returns an object that can get configuration values from a list of
# objects, and which can have any value overridden. It exposes an interface
# much like a W3 Storage.
#
# To make one, call `multicfg` with a list of config sources, all of which
# should respond to `get`.
#
# To use an object that behaves differently, use one of the utility functions:
#
# dict:  just wraps an object
# func:  wraps a function that will be called to get values
# env:   wraps an object like a Node `process.env`
# json:  expects a String containing a JSON object
# file:  tries to load a file containing JSON
# http:  tries to GET a URL containing JSON
# multi: allows you to nest multicfgs
#
# To use `file` or `http`, you should use `multicfg` asynchronously, by
# treating the result of the function as a promise.
#
# If the first argument isn't null (and is configurable), it will be used as
# storage when you call `getItem` and `deleteItem`.
multicfg = (stores...) ->
  multicfg.multi(stores)

# Promises to get a value, but the promise itself responds to `get`, so it can
# be used as-is if you're sure all the stores are synchronous. `prerequisite`
# is the promise that should resolve first (defaults to Promise.resolve).
promise = (get, prerequisite) ->
  prerequisite ?= Promise.resolve()
  result = prerequisite.then(-> { get })
  result.get = get
  result

# Promises to read a file
readFile = (path, encoding) ->
  new Promise (resolve, reject) ->
    require('fs').readFile path, encoding, (err, data) ->
      return reject(err) if err?
      resolve(data)
    
multicfg.dict = (store = {}) ->
  get = (k, v) -> store[k] || v
  promise(get)

multicfg.func = (func) ->
  get = (k, f) -> func(k, v) || v
  promise(get)

multicfg.env = (env, prefix) ->
  get = (k, v) ->
    k = k.toString().replace('.', '_').toUpperCase()
    k = "#{prefix}_#{k}" if prefix?
    env[k] || v
  promise(get)

multicfg.json = (str) ->
  json = JSON.parse(str)
  get = (k, v) -> json[k.toString()] || v
  promise(get)

multicfg.file = (path, encoding = 'utf8') ->
  json = {}
  get = (k, v) -> json[k] || v
  load = readFile(path, encoding).then (data) ->
    json = JSON.parse(data)
  promise(get, load)

multicfg.storage = (storage) ->
  get = (k, v) -> storage.getItem(k) || v
  promise(get)

multicfg.multi = (stores = [{}]) ->
  stores = stores.map (store) ->
    return multicfg.func(store) if typeof(store) is 'function'
    return multicfg.dict(store) unless typeof(store.get) is 'function'
    store
  store = (k) -> stores.find (store) -> store.get(k) isnt undefined
  get = (k, v) -> store[k] || v
  result = Promise.all(stores).then(-> { get })
  result.get = get
  result

@multicfg = multicfg
