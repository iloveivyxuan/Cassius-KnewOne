module HomeHelper
  def home_nav(action, options = {}, &block)
    li((action_name == action.to_s), options, &block)
  end

  def search_nav(type, default = false, options = {}, &block)
    li(((params[:type] == type) || (default && params[:type].blank?)), options, &block)
  end
end
