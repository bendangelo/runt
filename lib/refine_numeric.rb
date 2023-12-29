# replaced by active_support/core_ext/integer/time
module CoreExtensions
  module NumericExtention
    module ClassMethods
    end

    refine Numeric do
      def microseconds() Float(self  * (10 ** -6)) end unless self.instance_methods.include?('microseconds')
      def milliseconds() Float(self  * (10 ** -3)) end unless self.instance_methods.include?('milliseconds')
      def seconds() self end unless self.instance_methods.include?('seconds')
      def minutes() 60 * self end unless self.instance_methods.include?('minutes')
      def hours() 60 * 60 * self end unless self.instance_methods.include?('hours')
      def days() 24 * 60 * 60 * self end unless self.instance_methods.include?('days')
      def weeks() 7 * 24 * 60 * 60 * self end unless self.instance_methods.include?('weeks')
      def months() 30 * 24 * 60 * 60 * self end unless self.instance_methods.include?('months')
      def years() 365 * 24 * 60 * 60 * self end unless self.instance_methods.include?('years')
      def decades() 10 * 365 * 24 * 60 * 60 * self end unless self.instance_methods.include?('decades')
      # This causes RDoc to hurl:
      %w[
      microseconds milliseconds seconds minutes hours days weeks months years decades
      ].each{|m| alias_method m.chop, m}
    end

    # refine Numeric.singleton_class do
    #   prepend NumericExtention::ClassMethods
    # end

    
    end
  end
end
