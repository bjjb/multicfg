require 'pathname'
require 'json'
require 'yaml'

# A configuration loaded from multiple sources.
# TODO: proper rdoc
class Multicfg < Hash
  def initialize(prefix = nil)
    @prefix = prefix
  end

  def merge(another)
    self.class.merge(self, another)
  end

  def load(x)
    case x
    when Pathname then load(x.read)
    when Array    then load(Hash[*x])
    when IO       then load(read(io))
    when String   then load_or_parse(x)
    else               merge(filter(x.to_h))
    end
  end

  def parse(s)
    merge(YAML.load(s))
  end

  def read(io)
    YAML.load(io)
  end

  def load_or_parse(s)
    pathname = Pathname.new(s)
    return load(pathname) if pathname.readable?
    parse(s)
  end

  def filter(hash = {})
    regexp = /^#{@prefix}[_\-]/i if @prefix
    regexp ||= /^/
    hash.each_with_object({}) do |kv, h|
      h[$'.downcase.to_sym] = kv[1] if kv[0] =~ regexp
    end
  end

  def from_stream(io)
    io.read
  end

  class << self
    def merge(l, r)
      return r unless l.is_a?(Hash) && r.is_a?(Hash)
      r.each { |k, v| l[k] = merge(l[k], v) }
      l
    end

    def load(*args)
      args.reduce(new) { |a, e| a.load(e) }
    end
  end
end
