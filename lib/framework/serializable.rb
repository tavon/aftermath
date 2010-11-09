require 'yajl'

module Aftermath::Serializable
  module Dsl
    attr_writer :version
    def reconstitute(json)
      h = Yajl::Parser.parse(json)
      o = eval(h.delete('__name__')).new
      o.reconstitute(h)
    end

    def member(name, type = nil)
      _members[name] = type # for type info
      attr_accessor name
    end

    def property(name, type = nil)
      _members[name] = type # for type info
    end

    def members
      _members.keys
    end

    def version
      @version ||= 1
    end

    private
    def _members
      @_members ||= {}
    end
  end

  def initialize(data = nil)
    yield self if block_given?
    reconstitute(data) if data
  end

  def to_hash
    hsh = {:__name__ => self.class.name}
    members.each{|m| hsh[m] = instance_variable_get(:"@#{m}")}
    hsh
  end

  def to_json
    Yajl::Encoder.encode(to_hash)
  end

  def structural_version
    self.class.version
  end

  def reconstitute(data)
    data.each{|k,v| instance_variable_set(:"@#{k}", v) }
    self
  end

  def inspect
    PP.pp(to_hash, '')
  end

  private
  def members
    self.class.members
  end
end