module ParamValidator
  module Controller

    def self.included( other_module )
      other_module.extend ClassMethods
    end

    module ClassMethods

      def validate_parameters( *actions )
        before_filter :validate_parameters, :only => actions
      end

    end

    def validate_parameters
      klass_name = [self.class.name.gsub( /Controller/, '' ), "#{action_name.camelize}ParamValidator"].join( '::' )
      klass = klass_name.constantize
      validator = klass.new( params )
      unless validator.valid?
        raise ParamValidator::InvalidParameters.new( validator.full_errors.join( ', '))
      end
    rescue NameError => e
      raise if e.is_a?( NoMethodError )
      raise NotImplementedError,
            "please implement #{klass_name} param validator"
            e.backtrace
    end

  end
end
