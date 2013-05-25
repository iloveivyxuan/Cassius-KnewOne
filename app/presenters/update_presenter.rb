# -*- coding: utf-8 -*-
class UpdatePresenter < PostPresenter
  presents :update

  def path
    thing_update_path(update.thing, update)
  end

  def edit_path
    edit_thing_update_path(update.thing, update)
  end

  def share_content
    content = "在#{share_topic}, #{update.thing.title}更新了: "
    content += thing_update_url(update.thing, update)
  end
end
