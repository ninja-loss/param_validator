module ParamValidator
  class Base

    attr_reader :params

    def initialize( params )
      @params = params
    end

    def valid?
      self.class.specification.each do |param, spec|
        value = fetch_parameter( param )
        if spec[:required] && (value.nil? || value.empty?)
          errors << [param, 'must be present']
        end
      end

      errors.empty?
    end

    def errors
      @errors ||= []
    end

    def full_errors
      errors.map do |param_and_msg|
        param_and_msg.join( ' ' )
      end
    end

    def self.specification
      @@specification ||= {}
    end

    def self.validate( param, spec )
      specification[param] = spec
    end

  private

    def fetch_parameter( path )
      path( params, path )
    end

    def path( hash, *pathes )
      target = hash
      pathes.map! do |p|
        p.to_s.split(/[\/\.]+/)
      end
      pathes.flatten.each do |element|
        next if (element == nil || element == '')
        key, index = parse_element__(element)
        target = target[key] || target[key.to_s]
        return nil unless target
        if index
          raise "target=#{target.inspect} is not array. but specified index value." unless target.is_a?(Array)
          target = target[index]
          return nil unless target
        end
      end
      target
    end

    def parse_element__(elm_string)
      if elm_string =~ /^(.+)\[(\d+)\]$/
        [$1.to_sym, $2.to_i]
      elsif elm_string =~ /^(.+)_(\d+)$/
        [$1.to_sym, $2.to_i]
      else
        [elm_string.to_sym, nil]
      end
    end

  end
end
