class ThingListPresenter < ApplicationPresenter
  presents :thing_list

  def cover(size)
    if thing_list.items.empty?
      image_url('blank-list-cover.png')
    else
      thing_list.items.first.thing.cover.url(size)
    end
  end

  def share_content
    "来自 @KnewOne 的新奇酷榜单 #{thing_list.name}，里面收集了 #{thing_list.items.size} 个商品 #{thing_list_url(thing_list, refer: 'weibo')}"
  end
end
