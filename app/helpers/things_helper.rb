module ThingsHelper
  def render_mobile_buy(thing)
    case thing.stage
    when :dsell
      if user_signed_in?
        link_to_with_icon "购买", "fa fa-shopping-cart", "#", class: "btn btn-success btn-block", data: {toggle: "modal", target: "#mobile_buy_modal"}
      else
        link_to_with_icon "请登录后购买", "fa fa-sign-in", "#", class: "btn btn-danger btn-block", data: {toggle: "modal", target: "#login-modal"}
      end
    when :pre_order
      if user_signed_in?
        link_to_with_icon "购买", "fa fa-shopping-cart", "#", class: "btn btn-success btn-block", data: {toggle: "modal", target: "#mobile_buy_modal"}
      else
        link_to_with_icon "请登录后购买", "fa fa-sign-in", "#", class: "btn btn-danger btn-block", data: {toggle: "modal", target: "#login-modal"}
      end
    when :kick
      if user_signed_in? && thing.shop.present?
        link_to_with_icon "众筹", "fa fa-fire fa-lg", buy_thing_path(thing),
        title: thing.title, class: "btn btn-warning btn-block buy_button track_event", target: "_blank", rel: '_nofollow',
        data: {
          action: "buy",
          category: "kick",
          label: "buy+kick+#{thing.title}"
        }
      else
        link_to_with_icon "请登录后众筹", "fa fa-sign-in", "#", class: "btn btn-danger btn-block", data: {toggle: "modal", target: "#login-modal"}
      end
    when :domestic
      if user_signed_in? && thing.shop.present?
        link_to_with_icon "网购", "fa fa-location-arrow fa-lg", buy_thing_path(thing),
        title: thing.title, class: "btn btn-info btn-block buy_button track_event", target: "_blank", rel: '_nofollow',
        data: {
          action: "buy",
          category: "domestic",
          label: "buy+domestic+#{thing.title}"
        }
      else
        link_to_with_icon "请登录后网购", "fa fa-sign-in", "#", class: "btn btn-danger btn-block", data: {toggle: "modal", target: "#login-modal"}
      end
    when :abroad
      if user_signed_in? && thing.shop.present?
        link_to_with_icon "海淘", "fa fa-plane fa-lg", buy_thing_path(thing),
        title: thing.title, class: "btn btn-info btn-block buy_button track_event", target: "_blank", rel: '_nofollow',
        data: {
          action: "buy",
          category: "abroad",
          label: "buy+abroad+#{thing.title}"
        }
      else
        link_to_with_icon "请登录后海淘", "fa fa-sign-in", "#", class: "btn btn-danger btn-block", data: {toggle: "modal", target: "#login-modal"}
      end
    when :adoption
      render 'things/adopt', tp: present(thing)
    else
      nil
    end
  end

end
