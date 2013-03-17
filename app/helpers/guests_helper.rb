# -*- coding: utf-8 -*-
module GuestsHelper
  def guest_activation(guest)
    activate_guests_url(token: guest.token)
  end

  def guest_user(guest)
    user = guest.user
    if user
      link_to user.name, user
    else
      "未激活"
    end
  end
end
