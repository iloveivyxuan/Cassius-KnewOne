module Haven
  class LinksController < Haven::ApplicationController
    layout 'settings'

    def new
    end

    def create
    end

    def update
      things = params["url"].select { |e| !e.blank? }.map { |u| Thing.find(u.split("/").last) }
      thing_ids = things.map { |t| t.id.to_s }

      # associate categories & shop url.
      thing_categories = []
      things.each { |t| thing_categories += t.categories }
      thing_categories.uniq!
      thing_shop = things.map(&:shop).select { |t| !t.blank? }.first

      # clear links may be created before
      things.each { |t| t.delete_links }
      # set linked
      things.each do |t|
        t.links = thing_ids
        t.categories = thing_categories
        t.shop = thing_shop if t.shop.blank?
        t.save!
      end

      notify_sharers_of(things)

      redirect_to haven_links_path
    end

    def index
      @groups = Thing.linked.all.map { |t| t.links }.uniq
    end

    def show
      @things = Thing.find(params[:id]).links.map { |t| Thing.find(t) }
    end

    def destroy
      Thing.find(params[:id]).delete_links
      redirect_to haven_links_path
    end

    private

    def notify_sharers_of(things)
      newer_things = things.sort_by(&:created_at).reverse.take(things.count - 1)
      oldest_thing = things.sort_by(&:created_at).take(1).first
      knewone = User.where(id: '511114fa7373c2e3180000b4').first
      newer_things.each do |t|
        content = <<STR
您好，感谢您来到 KnewOne。
由于您分享的产品 <a href='#{thing_url(t)}'>#{t.title}</a> 之前已经被 <a href='#{user_url(oldest_thing.author)}'>#{oldest_thing.author.name}</a> 于 <a href='#{thing_url(oldest_thing)}'>#{oldest_thing.title}</a> 分享过，所以您的产品条目将被合并。您分享的产品页面将会保留，但会发生如下变化：相同产品的喜欢数、拥有数、短评和测评都将统一合并。

分享产品的帮助请点击 <a href="http://knewone.com/about">KnewOne 上手指南</a>
非常感谢您对 KnewOne 的关注，希望您能分享更多新奇酷的产品和体验，谢谢。
STR
        knewone.send_private_message_to(t.author, content)
      end

    end # notify_sharers_of

  end
end
