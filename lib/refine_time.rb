# Add precision +Runt::DPrecision+ to standard library class Time
require 'time'

module CoreExtensions
  module TimePrecision
    refine Time.singleton_class do
      def parse(*args)
        # wrap parse to set precision
        precision = if(args[0].instance_of?(Runt::DPrecision::Precision))
          args.shift
        else
          Runt::DPrecision::DEFAULT
        end

        _parse = super(*args)
        _parse.instance_variable_set(:@date_precision, precision)
        _parse
      end
    end

    refine Time do
      attr_writer :date_precision

      def initialize(*args)
        # supress warning: instance variable @date_precision not initialized
        @date_precision ||= nil

        @precision = if(args[0].instance_of?(Runt::DPrecision::Precision))
          args.shift
        else
          Runt::DPrecision::SEC
        end

        super(*args)
      end

      def to_yaml(options)
        if self.instance_variables.empty?
          self.super(options)
        else
          self.class.parse(self.to_s).super(options)
        end
      end

      def date_precision
        # supress warning: instance variable @date_precision not initialized
        @date_precision ||= nil

        return @date_precision unless @date_precision.nil?
        return Runt::DPrecision::DEFAULT
      end
    end

    

   
  end
end
