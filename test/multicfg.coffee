{ expect } = require 'chai'
multicfg = require '../'

describe 'multicfg.dict', ->
  cfg = multicfg.dict(a: 'A')
  it 'responds to get with a default', ->
    expect(cfg.get('x', 'y')).to.eq('y')
  it 'works with a seed dict', ->
    expect(cfg.get('a')).to.eq('A')
  it 'acts like a promise', ->
    expect(cfg.then).to.be.a 'function'
  it 'resolves to the store', (done) ->
    cfg.then (cfg) ->
      expect(cfg.get('a')).to.eq('A')
      done()

describe 'multicfg.storage', ->
  storage = getItem: (x) -> "~~#{x}~~" unless x is 'NOTHING'
  cfg = multicfg.storage(storage)
  it 'responds to get with a default', ->
    expect(cfg.get('NOTHING', 'y')).to.eq('y')
  it 'works with the storage', ->
    expect(cfg.get('a')).to.eq('~~a~~')
  it 'acts like a promise', ->
    expect(cfg.then).to.be.a 'function'
  it 'resolves to the store', (done) ->
    cfg.then (cfg) ->
      expect(cfg.get('a')).to.eq('~~a~~')
      done()

describe 'multicfg.json', ->
  json = '{ "a": "b" }'
  cfg = multicfg.json(json)
  it 'responds to get with a default', ->
    expect(cfg.get('NOTHING', 'y')).to.eq('y')
  it 'works with the storage', ->
    expect(cfg.get('a')).to.eq('b')
  it 'acts like a promise', ->
    expect(cfg.then).to.be.a 'function'
  it 'resolves to the store', (done) ->
    cfg.then (cfg) ->
      expect(cfg.get('a')).to.eq('b')
      done()

describe 'multicfg.env', ->
  env = FOO: 'bar', BLUE_BELL: 123
  describe 'with a prefix', ->
    cfg = multicfg.env(env, 'BLUE')
    it 'responds to get with a default', ->
      expect(cfg.get('NOTHING', 'y')).to.eq('y')
    it 'works with the storage', ->
      expect(cfg.get('bell')).to.eq(123)
    it 'acts like a promise', ->
      expect(cfg.then).to.be.a 'function'
    it 'resolves to the store', (done) ->
      cfg.then (cfg) ->
        expect(cfg.get('bell')).to.eq(123)
        done()
  describe 'with no prefix', ->
    cfg = multicfg.env(env)
    it 'responds to get with a default', ->
      expect(cfg.get('NOTHING', 'y')).to.eq('y')
    it 'works with the storage', ->
      expect(cfg.get('foo')).to.eq('bar')
    it 'works with dots', ->
      expect(cfg.get('blue.bell')).to.eq(123)
    it 'acts like a promise', ->
      expect(cfg.then).to.be.a 'function'
    it 'resolves to the store', (done) ->
      cfg.then (cfg) ->
        expect(cfg.get('foo')).to.eq('bar')
        done()

describe 'multicfg.file', ->
  { writeFile, unlink } = require 'fs'
  cfg = null
  before (done) ->
    writeFile('x.json', '{"a": "b"}', done)
    cfg = multicfg.file('x.json')
  after  (done) ->
    unlink('x.json', done)
  it 'responds to get with a default', ->
    expect(cfg.get('NOTHING', 'y')).to.eq('y')
  it 'acts like a promise', ->
    expect(cfg.then).to.be.a 'function'
  it 'resolves to the store', (done) ->
    cfg.then (cfg) ->
      expect(cfg.get('a')).to.eq('b')
      done()

describe 'multicfg.multi', ->
  store1 = { a: 123, c: 999 }
  store2 = { a: 234, b: 888 }
  cfg = multicfg.multi([store1, store2])
  it 'responds to get with a default', ->
    expect(cfg.get('NOTHING', 'y')).to.eq('y')
  it 'acts like a promise', ->
    expect(cfg.then).to.be.a 'function'
  it 'resolves to the store', (done) ->
    cfg.then (cfg) ->
      expect(cfg.get('a')).to.eq('b')
      done()

