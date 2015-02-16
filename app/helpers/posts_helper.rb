module PostsHelper

  def load_post_resources(content)
    html_doc = Nokogiri::HTML.fragment(content)
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
        if (list = ThingList.where(id: key).first)
          result = render 'thing_lists/thing_list', thing_list: list, layout: browser.desktop? ? :quintet : :grid
        end
      when 'review'
        if (review = Review.where(id: key).first)
          result = render 'home/hot_review', review: review
        end
      else
        result = '<p class="knewone-embed-tip">无效的资源。</p>'
      end

      result ||= '<p class="knewone-embed-tip">无效的资源。</p>'
      element.add_child(result)
    end
    html_doc.to_html
  end

end
