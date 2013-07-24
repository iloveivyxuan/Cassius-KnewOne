# -*- coding: utf-8 -*-
module ThingsHelper
  def thing_title(thing)
    [thing.title, thing.subtitle].reject(&:blank?).join(' - ')
  end

  def things_sort(sort)
    case sort
    when "self_run"
      "自营产品"
    when "fancy"
      "热门产品"
    else
      "最新产品"
    end
  end
end
