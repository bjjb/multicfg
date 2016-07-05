multicfg
========

A little helper for working with multiple key/value sources as though they're
one.

Ships with wrappers for loading JSON files, using environment variables, and
using a browser's local storage.

Works with promises for asynchronous sources.

Runs on Node and in the browser.

Installation
------------

With Node:

    npm install multicfg

With bower

    bower install multicfg

Manually, add the following to your web page

    <script src='https://cdn.rawgit.com/bjjb/multicfg/0.1.0/multicfg.js'>

Usage example
-------------

multicfg cascades the configs you pass into it.

```
  // Let's say you have JSON loaded from a server
  var jsonConfig = "{ "colors": ["black", "blue"], "debug": "false" }"
  // ...and the following in localStorage
  localStorage.debug = true
  // You make a multicfg with those...
  var cfg = multicfg(localStorage, jsonConfig)
  console.log(cfg.get('colors') // ["black", "blue"], from the JSON
  console.log(cfg.get('debug')  // true, from localStorage
```

It can also make use of environment-like variables, with an optional prefix

```
  var multicfg = require('multicfg')
  process.env.MY_VERBOSE = "yes"
  var defaults = { foo: "bar", verbose: false }
  var cfg = multicfg(multicfg.env(process.env, 'MY'), defaults)
  console.log(cfg.get('verbose') // "yes", from the environment
  console.log(cfg.get('foo')     // "bar", from the defaults
```

Also useful is the ability to read from a file. Suppose you have your app
configuration in `~/.myapp.conf`, you can load it up with

```
  var userConfig = multicfg.file(process.env.HOME + "/myapp.conf")
```

In this case, `userConfig` is empty until the asynchronous load is completed,
so you can treat it (and all configs) as a promise.

```
  userConfig.then(function(cfg) { console.log(cfg.get('myvar')) })
```

This also works if you put `userConfig` into a `multicfg` - `multicfg` is a
promise which responds to `get` and which resolves to itself after all of its
component configs have resolved.

If a second argument is passed into `get`, it will be returned if no matching
config value could be found.

See the [source][] for more.

[source]: https://github.com/bjjb/multicfg/blob/master/multicfg.coffee
