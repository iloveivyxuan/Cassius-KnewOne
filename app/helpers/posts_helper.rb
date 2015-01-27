module PostsHelper

  def load_post_resources(post)
    html_doc = Nokogiri::HTML.fragment(post.content)
    html_doc.css('.knewone-embed:empty').each do |element|
      type = element["data-knewone-embed-type"]
      key = element["data-knewone-embed-key"]
      options = element["data-knewone-embed-options"]
      photos = JSON.parse(options)["photos"] if options

      case type
      when 'thing'
        slugs = key.split(',')
        things = Thing.in(slugs: slugs).sort_by { |thing| slugs.index(thing.slug) }
        photos = options ? photos.split(',') : Array.new(things.size, "")
        result = render partial: 'things/embed_thing', collection: things.zip(photos), locals: { klass: (slugs.size > 1) ? 'col-sm-6' : 'col-sm-12' }, as: 'embed'
      when 'list'
        list = ThingList.find key
        result = render 'thing_lists/thing_list', thing_list: list, layout: browser.desktop? ? :quintet : :grid
      when 'review'
        review = Review.find key
        result = render partial: 'home/hot_review', collection: [review]
      else
        result = '<p class="knewone-embed-tip">无效的资源。</p>'
      end

      element.add_child(result)
    end
    html_doc.to_html
  end

end
