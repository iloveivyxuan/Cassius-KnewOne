# -*- coding: utf-8 -*-
class FeelingPresenter < PostPresenter
  presents :feeling

  def content
    content = auto_link @object.content, :all, target: '_blank'
    feeling.content_users.each do |u|
      content.gsub! "@#{u.name}", link_to("@#{u.name}", u)
    end
    simple_format content
  end

  def path
    thing_feeling_path(feeling.thing, feeling)
  end

  def edit_path
    edit_thing_feeling_path(feeling.thing, feeling)
  end

  def share_content
    content = "我在 #{share_topic}"
    content += if feeling.author == current_user
                 "对 #{feeling.thing.title}发布了感想: "
               else
                 "分享了 @#{feeling.author.name} 对 #{feeling.thing.title}的感想: "
               end
    content += thing_feeling_url(feeling.thing, feeling, refer: 'weibo')
    content += " " + feeling.content
  end

  def share_pic(size)
    feeling.thing.cover.url size
  end
end
