module ThingsHelper
  def render_mobile_buy(thing)
    case thing.stage
    when :dsell
      if user_signed_in?
        link_to_with_icon "购买", "fa fa-shopping-cart", "#",
        class: "btn btn-success btn-buy-mobile track_event",
        data: data_with_buy_tracker("dsell", thing.title, {toggle: "modal", target: "#mobile_buy_modal"})
      else
        link_to_with_icon "请登录后购买", "fa fa-sign-in", "#",
        class: "btn btn-danger btn-buy-mobile track_event",
        data: data_with_login_tracker("dsell", thing.title)
      end
    when :pre_order
      if user_signed_in?
        link_to_with_icon "购买", "fa fa-shopping-cart", "#",
        class: "btn btn-success btn-buy-mobile track_event",
        data: data_with_buy_tracker("pre_order", thing.title, {toggle: "modal", target: "#mobile_buy_modal"})
      else
        link_to_with_icon "请登录后购买", "fa fa-sign-in", "#",
        class: "btn btn-danger btn-buy-mobile track_event",
        data: data_with_login_tracker("pre_order", thing.title)
      end
    when :kick
      if user_signed_in? && thing.shop.present?
        link_to_with_icon "众筹", "fa fa-fire fa-lg", buy_thing_path(thing),
        title: thing.title, class: "btn btn-warning btn-buy-mobile buy_button track_event", target: "_blank", rel: 'nofollow',
        data: data_with_buy_tracker("kick", thing.title)
      else
        link_to_with_icon "请登录后众筹", "fa fa-sign-in", "#",
        class: "btn btn-danger btn-buy-mobile track_event",
        data: data_with_login_tracker("kick", thing.title)
      end
    when :domestic
      if user_signed_in? && thing.shop.present?
        link_to_with_icon "网购", "fa fa-location-arrow fa-lg", buy_thing_path(thing),
        title: thing.title, class: "btn btn-info btn-buy-mobile buy_button track_event", target: "_blank", rel: 'nofollow',
        data: data_with_buy_tracker("domestic", thing.title)
      else
        link_to_with_icon "请登录后网购", "fa fa-sign-in", "#",
        class: "btn btn-danger btn-buy-mobile track_event",
        data: data_with_login_tracker("domestic", thing.title)
      end
    when :abroad
      if user_signed_in? && thing.shop.present?
        link_to_with_icon "海淘", "fa fa-plane fa-lg", buy_thing_path(thing),
        title: thing.title, class: "btn btn-info btn-buy-mobile buy_button track_event", target: "_blank", rel: 'nofollow',
        data: data_with_buy_tracker("abroad", thing.title)
      else
        link_to_with_icon "请登录后海淘", "fa fa-sign-in", "#",
        class: "btn btn-danger btn-buy-mobile track_event",
        data: data_with_login_tracker("abroad", thing.title)
      end
    when :adoption
      render 'things/adopt', tp: present(thing)
    else
      nil
    end
  end

  def data_with_buy_tracker(category, label, data=nil)
    tracker = {
      action: "buy",
      category: "buy+#{category}",
      label: "buy+#{category}+#{label}"
    }

    data ? tracker.merge(data) : tracker
  end

  def data_with_login_tracker(category, label)
    {
      action: "login",
      category: "login+#{category}",
      label: "login+#{category}+#{label}",

      toggle: "modal",
      target: "#login-modal"
    }
  end

  def haven_filters
    {
      'no_link' => '无购买链接',
      'no_category' => '无分类',
      'no_price' => '无价格',
      'no_tag' => '无标签',
      'no_official' => '无来源',
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
      'priority_desc' => '优先度正序'
    }
  end

  def haven_queries
    {
      "categories" => "分类",
      "shop" => "链接",
      "title" => "标题 & 副标题",
      "brand" => "品牌",
      "tag" => "标签",
      "official" => "来源网站"
    }
  end

end
