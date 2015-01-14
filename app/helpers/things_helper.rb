module ThingsHelper
  def render_mobile_buy_button(thing)
    case thing.stage
    when :dsell
      if user_signed_in?
        link_to_with_icon "现在购买", "fa fa-shopping-cart", "#",
        class: "btn btn-buy-mobile--shorten",
        data: data_with_buy_tracker("dsell", thing.title, {toggle: "modal", target: "#mobile_buy_modal"})
      elsif browser.wechat?
        link_to_with_icon "现在购买", "fa fa-sign-in", login_path,
        class: "btn btn--orange--true btn--login btn-buy-mobile",
        data: data_with_login_tracker("dsell", thing.title, !browser.wechat?)
      else
        link_to_with_icon "请登录后购买", "fa fa-sign-in", login_path,
        class: "btn btn--login btn-buy-mobile",
        data: data_with_login_tracker("dsell", thing.title, !browser.wechat?)
      end
    when :pre_order
      if user_signed_in?
        link_to_with_icon "现在购买", "fa fa-shopping-cart", "#",
        class: "btn btn-buy-mobile--shorten",
        data: data_with_buy_tracker("pre_order", thing.title, {toggle: "modal", target: "#mobile_buy_modal"})
      elsif browser.wechat?
        link_to_with_icon "现在购买", "fa fa-sign-in", login_path,
        class: "btn btn--orange--true btn--login btn-buy-mobile",
        data: data_with_login_tracker("pre_order", thing.title, !browser.wechat?)
      else
        link_to_with_icon "请登录后购买", "fa fa-sign-in", login_path,
        class: "btn btn--login btn-buy-mobile",
        data: data_with_login_tracker("pre_order", thing.title, !browser.wechat?)
      end
    when :kick
      if user_signed_in? && thing.shop.present?
        link_to_with_icon "众筹", "fa fa-fire fa-lg", buy_thing_path(thing),
        title: thing.title, class: "btn btn--kick btn-buy-mobile buy_button", target: "_blank", rel: 'nofollow',
        data: data_with_buy_tracker("kick", thing.title)
      else
        link_to_with_icon (browser.wechat? ? "请登录后购买" : "请登录后众筹"), "fa fa-sign-in", login_path,
        class: "btn btn--login btn-buy-mobile",
        data: data_with_login_tracker("kick", thing.title, !browser.wechat?)
      end
    when :domestic
      if user_signed_in? && thing.shop.present?
        link_to_with_icon "网购", "fa fa-location-arrow fa-lg", buy_thing_path(thing),
        title: thing.title, class: "btn btn--online_shopping btn-buy-mobile buy_button", target: "_blank", rel: 'nofollow',
        data: data_with_buy_tracker("domestic", thing.title)
      else
        link_to_with_icon (browser.wechat? ? "请登录后购买" : "请登录后网购"), "fa fa-sign-in", login_path,
        class: "btn btn--login btn-buy-mobile",
        data: data_with_login_tracker("domestic", thing.title, !browser.wechat?)
      end
    when :abroad
      if user_signed_in? && thing.shop.present?
        link_to_with_icon "海淘", "fa fa-plane fa-lg", buy_thing_path(thing),
        title: thing.title, class: "btn btn--online_shopping btn-buy-mobile buy_button", target: "_blank", rel: 'nofollow',
        data: data_with_buy_tracker("abroad", thing.title)
      else
        link_to_with_icon (browser.wechat? ? "请登录后购买" : "请登录后海淘"), "fa fa-sign-in", login_path,
        class: "btn btn--login btn-buy-mobile",
        data: data_with_login_tracker("abroad", thing.title, !browser.wechat?)
      end
    else
      nil
    end
  end

  def render_mobile_adoption_button(thing)
    if thing.adoption
      render 'things/adopt', tp: present(thing)
    end
  end

  def haven_filters
    {
      'no_link' => '无购买链接',
      'no_category' => '无分类',
      'no_price' => '无价格',
      'no_tag' => '无标签',
      'no_official' => '无来源',
      'no_brand' => '无品牌',
      'concept' => '研发中',
      'kick' => '众筹中',
      'pre_order' => '预售',
      'domestic' => '国内导购',
      'abroad' => '国外海淘',
      'dsell' => '自销',
      'feelings_count' => '按短评数排序',
      'reviews_count' => '按评测数排序',
      'heat' => '按热度排序',
      'priority_asc' => '优先度倒序',
      'priority_desc' => '优先度正序',
      'created_at_desc' => '创建时间正序',
      'created_at_asc' => '创建时间倒序'
    }
  end

  def haven_queries
    {
      "category" => "分类",
      "shop" => "链接",
      "title" => "标题 & 副标题",
      "brand" => "品牌",
      "official" => "来源网站",
      "price_unit" => '价格单位'
    }
  end

  def merge_params(original_params, new_params)
    original_params.merge(new_params).select { |k, v| v != nil }
  end

  def original_params
    {
      :price_h => params[:price_h],
      :price_l => params[:price_l],
      :categories => params[:categories],
      :order_by => params[:order_by]
    }
  end

  def categories_options
    navs = [%w(所有分类 all)]
    Category.desc(:things_count).limit(9).map { |c| navs << [c.name, c.slug] }
    options = navs.each { |nav| nav << { 'data-url' => shop_path(merge_params(original_params, categories: nav[1])) } }
    [navs, options]
  end

  def price_options
    p = Thing::PRICE_LIST
    navs = [["所有价格", "all", "all", {"data-url"=>"/shop?price=all"}]]
    (1..p.size-1).each.map { |i| navs << [price_format(p[i-1], p[i]), p[i-1], p[i]] }
    navs[navs.size - 1] = ["￥#{navs.last[1]}+", navs.last[1], navs.last[2]]
    options = navs.each { |nav| nav << { 'data-url' => shop_path(merge_params(original_params, price_l: nav[1], price_h: nav[2])) } }
    [navs, options]
  end

  def order_options
    navs = [
            %w(最新 news),
            %w(推荐 recommended),
            %w(最热 hits),
            %w(价格高到低 price_h_l),
            %w(价格低到高 price_l_h)
           ]
    options = navs.map { |nav| nav << { 'data-url' => shop_path(merge_params(original_params, order_by: nav[1])) } }
    [navs, options]
  end

  def price_format(l, h)
    if h == Thing::PRICE_LIST.last
      "￥#{l}+"
    else
      "￥#{l} ~ ￥#{h}"
    end
  end

  def thing_index_title
    if @category.present?
      "#{@category.name}|#{@category.name}产品"
    elsif @brand.present?
      "#{@brand.brand_text}|#{@brand.brand_text}产品"
    elsif @tag.present?
      "#{@tag.name}|#{@tag.name}产品"
    else
      "产品"
    end
  end

  def thing_index_keywords
    if @category.present?
      "#{@category.name}"
    elsif @brand.present?
      [@brand.en_name, @brand.zh_name].compact.join(",")
    else
      nil
    end
  end

  def categories_things_path(*c)
    "/things/categories/#{c.map(&:slug).join('/')}"
  end

  def brands_categories_things_path(brand, category)
    "/things/brand/#{brand.id}/categories/#{category.slug}"
  end
end
