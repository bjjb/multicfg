require 'test_helper'
require 'tmpdir'
require 'yaml'

describe Multicfg do
  it 'can merge two hashes' do
    Multicfg.merge({ foo: 1 }, foo: 2)[:foo].must_equal(2)
  end

  describe 'merging two objects' do
    it 'returns the second object, unless they are both hashes' do
      Multicfg.merge(:a, :b).must_equal :b
      Multicfg.merge(:a, 1).must_equal 1
      Multicfg.merge({ a: 1 }, 2).must_equal 2
      Multicfg.merge(1, a: 1).must_equal a: 1
      Multicfg.merge({ a: 1 }, 1).must_equal 1
    end

    it 'merges the second hash into the first' do
      h = { a: 1, b: 2, c: { d: { e: 3 } } }
      Multicfg.merge(h, b: 3, c: { d: { e: 4 } }, e: 9).must_be_same_as(h)
      h.must_equal a: 1, b: 3, c: { d: { e: 4 } }, e: 9
    end
  end

  describe 'loading a list of sources' do
    d = Dir.mktmpdir('multicfg')
    f1 = File.join(d, 'f1')
    f2 = File.join(d, 'f2')
    File.open(f1, 'w') { |f| YAML.dump({ a: { b: { c: 123 } }, x: 11 }, f) }
    File.open(f2, 'w') { |f| YAML.dump({ a: { b: { c: 'c' } }, y: 22 }, f) }
    result = Multicfg.load(f1, f2)
    it 'gets the right hash' do
      result.must_equal a: { b: { c: 'c' } }, x: 11, y: 22
    end
  end

  describe 'loading from ENV' do
    env = { 'MY_FOO' => '1', 'MY_BAR' => 2, 'BAZ' => 3 }
    it 'loads the right hash' do
      Multicfg.new('my').load(env).must_equal foo: '1', bar: 2
    end
  end

  describe 'loading from options' do
    options = %w(my-foo 1 my-bar 2 baz 3)
    it 'loads the right hash' do
      Multicfg.new('my').load(options).must_equal foo: '1', bar: '2'
    end
  end
end
