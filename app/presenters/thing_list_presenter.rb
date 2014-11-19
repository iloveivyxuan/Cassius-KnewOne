class ThingListPresenter < ApplicationPresenter
  presents :thing_list

  def cover(size)
    if thing_list.items.empty?
      image_url('blank-list-cover.png')
    else
      thing_list.items.first.thing.cover.url(size)
    end
  end

  def share_author_name
    if @object.author.current_auth && @object.author.current_auth.name.present?
      '@' + @object.author.current_auth.name
    else
      @object.author.name || ''
    end
  end

  def share_content
    "推荐 #{share_author_name} 的 @KnewOne 列表【#{thing_list.name}】，非常喜欢 #{thing_list_url(thing_list, refer: 'weibo')}"
  end
end
