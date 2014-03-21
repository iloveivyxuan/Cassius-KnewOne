module HomeHelper
  def home_nav(action, options = {}, &block)
    li((action_name == action.to_s), options, &block)
  end
end
