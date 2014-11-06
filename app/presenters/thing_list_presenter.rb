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
    "这是来自剁手站 @KnewOne 的新奇酷列表【#{thing_list.name}】，里面有各种好东西，感觉非常赞！真是忍不住剁手啊 →_→ #{thing_list_url(thing_list, refer: 'weibo')}"
  end
end
