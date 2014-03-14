module Aftermath
  extend ActiveSupport::Concern

  module ClassMethods
    # only a true value can be triggered
    def need_aftermath(*args)
      args.each do |m|
        send :alias_method, :"_#{m}", m
        define_method m do |*args|
          if send :"_#{m}", *args
            AftermathHandler.send :"#{self.model_name.param_key}_#{m.to_s}", self
          end
        end
      end
    end
  end
end
