require 'attribute_struct'

module SparkleAttribute

  # TODO: look at the docs for Fn stuff. We can probably just map
  # simple ones with a bit of string manipulations
  
  def _cf_join(*args)
    options = args.detect{|i| i.is_a?(Hash) && i[:options]} || {:options => {}}
    args.delete(options)
    unless(args.size == 1)
      args = [args]
    end
    {'Fn::Join' => [options[:options][:delimiter] || '', *args]}
  end
  
  def _cf_ref(thing)
    thing = _process_key(thing, :force) if thing.is_a?(Symbol)
    {'Ref' => thing}
  end

  def _cf_map(thing, key, *suffix)
    suffix = suffix.map do |item|
      if(item.is_a?(Symbol))
        _process_key(item, :force)
      else
        item
      end
    end
    thing = _process_key(thing, :force) if thing.is_a?(Symbol)
    key = _process_key(key, :force) if key.is_a?(Symbol)
    {'Fn::FindInMap' => [_process_key(thing), {'Ref' => _process_key(key)}, *suffix]}
  end

  def _cf_attr(*args)
    args = args.map do |thing|
      if(thing.is_a?(Symbol))
        _process_key(thing, :force)
      else
        thing
      end

    end
    {'Fn::GetAtt' => args}
  end

  def _cf_base64(arg)
    {'Fn::Base64' => arg}
  end

  def rhel?
    !!@platform[:rhel]
  end

  def debian?
    !!@platform[:debian]
  end

  def _platform=(plat)
    @platform || __hashish
    @platform.clear
    @platform[plat.to_sym] = true
  end
  
end

AttributeStruct.send(:include, SparkleAttribute)
