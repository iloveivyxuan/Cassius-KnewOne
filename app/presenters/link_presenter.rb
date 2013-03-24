# -*- coding: utf-8 -*-
class LinkPresenter < PostPresenter
  presents :link
  delegate :url, to: :link

  def path
    thing_link_path(link.thing, link)
  end

  def edit_path
    edit_thing_link_path(link.thing, link)
  end

  def host
    URI.parse(link.url).host
  end

  def full_title
    link_to "#{title}(#{host})", url, target: "_blank"
  end

  def diggers_count
    dc = link.diggers.count
    dc <= 0 and return
    content_tag :small, dc.to_s
  end

  def share_content
    content = "我在#{share_topic}分享了一条关于#{link.thing.title}的新闻: "
    content += thing_link_url(link.thing, link)
  end
end
