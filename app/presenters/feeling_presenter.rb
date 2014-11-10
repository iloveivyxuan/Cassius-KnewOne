class FeelingPresenter < PostPresenter
  presents :feeling

  def content
    content = auto_link @object.content, :all, target: '_blank'
    content = simple_format content

    feeling.content_users.each do |u|
      content.gsub! "@#{u.name}", link_to("@#{u.name}", u,
                                          data: {'profile-popover' => u.id.to_s})
    end

    content.html_safe
  end

  def path
    thing_feeling_path(feeling.thing, feeling)
  end

  def edit_path
    edit_thing_feeling_path(feeling.thing, feeling)
  end

  def share_content
    if feeling.author == current_user
      "我在 #{share_topic} 对 #{feeling.thing.title} 发布了短评: "
    else
      "我在 #{share_topic} 分享了 #{share_author_name} 对 #{feeling.thing.title} 的短评: "
    end + summary(80) + " " + thing_feeling_url(feeling.thing, feeling, refer: 'weibo')
  end

  def share_pic(size)
    feeling.cover.url(size) or feeling.thing.cover.url(size)
  end
end
