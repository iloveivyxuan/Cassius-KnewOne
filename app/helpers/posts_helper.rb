module PostsHelper

  def load_post_resources(content, version = :web)
    is_mobile = version == :app ? true : browser.mobile?

    html_doc = Nokogiri::HTML.fragment(content)
    html_doc.css('.knewone-embed:empty').each do |element|
      type = element["data-knewone-embed-type"]
      key = element["data-knewone-embed-key"]
      options = element["data-knewone-embed-options"]
      photos = JSON.parse(options)["photos"] if options

      case type
      when 'thing'
        slugs = key.split(',')
        things = Thing.in(slugs: slugs).sort_by { |thing| slugs.index(thing.slug) || slugs.size }
        photos = options ? photos.split(',') : Array.new(things.size, "")
        result = render partial: 'things/embed_thing', collection: things.zip(photos), locals: { klass: (slugs.size > 1 ? 'col-sm-6' : 'col-sm-12'), is_mobile: is_mobile}, as: 'embed'
      when 'list'
        if (list = ThingList.where(id: key).first)
          result = render 'thing_lists/thing_list', thing_list: list, layout: !is_mobile ? :quintet : :grid
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

    case version
    when :app
      html_doc.css('img.js-lazy').remove_class('js-lazy').each do |img|
        img['src'] = img['data-original']
        img.remove_attribute('data-original')
      end
    end

    html_doc.to_html
  end

end
