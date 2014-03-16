module Aftermath
  extend ActiveSupport::Concern

  module ClassMethods
    RAILS_MAGIC_METHODS = [:create, :save, :update]
    # only a true value can be triggered
    def need_aftermath(*args)
      args.each do |m|
        if RAILS_MAGIC_METHODS.include? m
          send :"after_#{m}" do
            AftermathHandler.send :"#{self.model_name.to_s.underscore}_#{m.to_s}", self
          end
        else
          send :alias_method, :"_#{m}", m
          define_method m do |*args|
            if send :"_#{m}", *args
              AftermathHandler.send :"#{self.model_name.underscore}_#{m.to_s}", self
            end
          end
        end
      end
    end
  end
end
