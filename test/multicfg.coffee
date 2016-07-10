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
  it 'does not require an argument', ->
    cfg = multicfg.dict()
    expect(cfg.get('x')).to.eq(undefined)
    expect(cfg.get('x', 'bar')).to.eq('bar')

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
  cfg = _warn = null
  before (done) ->
    writeFile('x.json', '{"a": "b"}', done)
    cfg = multicfg.file('x.json')
    _warn = console.warn
    console.warn = ->
  after  (done) ->
    console.warn = _warn
    unlink('x.json', done)
  it 'responds to get with a default', ->
    expect(cfg.get('NOTHING', 'y')).to.eq('y')
  it 'acts like a promise', ->
    expect(cfg.then).to.be.a 'function'
  it 'resolves to the store', (done) ->
    cfg.then (cfg) ->
      expect(cfg.get('a')).to.eq('b')
      done()
  it 'ignores missing files', ->
    cfg = multicfg.file('/no/such/path')
    expect(cfg.get('a')).to.eq(undefined)
    expect(cfg.get('a', 'A')).to.eq('A')
  it 'does not blow up on missing files', (done) ->
    multicfg.file('/no/such/thing').then (cfg) ->
      expect(cfg.get('a', 'A')).to.eq('A')
      done()
    .catch(done)

describe 'multicfg', ->
  s1 = { a: 123, c: 999 }
  s2 = (k) -> 888 if k is 'b'
  s3 = '{"d": 777}'
  s4 = multicfg.env({MY_E: 555}, 'MY')
  cfg = multicfg(s1, s2, s3, s4)
  it 'responds to get with a default', ->
    expect(cfg.get('NOTHING', 'y')).to.eq('y')
  it 'acts like a promise', ->
    expect(cfg.then).to.be.a 'function'
  it 'resolves to the store', (done) ->
    cfg.then (cfg) ->
      expect(cfg.get('a')).to.eq(123)
      expect(cfg.get('b')).to.eq(888)
      expect(cfg.get('c')).to.eq(999)
      expect(cfg.get('d')).to.eq(777)
      expect(cfg.get('e')).to.eq(555)
      done()
    .catch(done)
