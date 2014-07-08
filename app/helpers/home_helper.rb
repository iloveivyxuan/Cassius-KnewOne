module HomeHelper
  def search_nav(text, type, href, default = false, options = {})
    if (default && params[:type].blank?) || params[:type] == type
      options[:class] = "#{options[:class]} btn btn-default active"
    else
      options[:class] = "#{options[:class]} btn btn-default"
    end

    link_to text, href, options
  end

  def activities_size
    Thing.all.size + Review.all.size
  end

  def paginate_nav
    paginate Kaminari.paginate_array([], total_count: activities_size).page(params[:page]).per(60)
  end
end
