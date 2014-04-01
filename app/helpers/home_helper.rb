module HomeHelper
  def home_nav(action, options = {}, &block)
    li((action_name == action.to_s), options, &block)
  end

  def search_nav(text, type, href, default = false, options = {})
    if (default && params[:type].blank?) || params[:type] == type
      options[:class] = "#{options[:class]} btn btn-default active"
    else
      options[:class] = "#{options[:class]} btn btn-default"
    end

    link_to text, href, options
  end
end
