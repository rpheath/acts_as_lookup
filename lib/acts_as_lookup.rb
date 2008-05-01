module RPH
  module ActsAsLookup
    def self.included(base)
      base.extend ActMethods
    end
    
    module ActMethods
      def acts_as_lookup(field_to_select, optionz={})
        raise(Error::InvalidParams, Error::InvalidParams.message) if field_to_select.blank?
        raise(Error::InvalidAttr, Error::InvalidAttr.message) unless self.new.respond_to?(field_to_select)
        
        options = {
          :default_text => '--',
          :order        => "#{field_to_select.to_s}"
        }.merge!(optionz)
      
        class_inheritable_accessor :options, :field_to_select
        extend ClassMethods
      
        self.options = options
        self.field_to_select = field_to_select.to_sym
      end
    end
  
    module ClassMethods
      def options_for_select
        rows = self.find(:all, :conditions => (options[:conditions] || {}), :order => options[:order])
        [[options[:default_text], nil]] + rows.collect { |r| [r.send(field_to_select), r.id] }
      end
    end
  
    module ViewHelpers
      def lookup_for(obj, f_key, options={}, html_options={})
        begin
          klass = f_key.to_s.gsub(/_id$/, '').classify.constantize 
        rescue NameError
          raise(Error::InvalidModel, Error::InvalidModel.message)
        end
        raise(Error::InvalidLookup, Error::InvalidLookup.message) unless klass && klass.respond_to?(:field_to_select) && klass.respond_to?(:options_for_select)
        select(obj.to_sym, f_key.to_sym, klass.options_for_select, options, html_options)
      end
    end
    
    module Error
      class CustomError < RuntimeError
        # getter/setter for setting custom error messages
        def self.message(msg=nil); msg.nil? ? @message : self.message = msg; end
        def self.message=(msg); @message = msg; end
      end

      class InvalidParams < CustomError
        message "must pass an attr to `acts_as_lookup' for the selection list (i.e. acts_as_lookup :title)"
      end
      class InvalidAttr < CustomError
        message "attr passed to `acts_as_lookup' does not exist"
      end
      class InvalidLookup < CustomError
        message "model passed to `lookup_for' does not have the `act_as_lookup' declaration"
      end
      class InvalidModel < CustomError
        message "model passed to `lookup_for' does not seem to exist"
      end
    end
  end
end