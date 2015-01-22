module EntriesHelper

  def entry_title(entry)
    entry.title.present? ? entry.title : entry.post.title
  end

  def active_nav_tab(entry)
    provide :sidebar_nav, Entry::CATEGORIES[entry.category]
  end

  def sidebar_tab(tab, options = {})
    options[:class] ||= ''
    if content_for(:sidebar_nav) == tab.to_s || options[:nav] == tab.to_s
      options[:class] += ' active'
    end
    content_tag(:li, options) {yield}
  end

  def load_entry_resources(post)
    html_doc = Nokogiri::HTML.fragment(post.content)
    html_doc.css('.knewone-embed:empty').each do |element|
      type = element["data-knewone-embed-type"]
      key = element["data-knewone-embed-key"]
      options = element["data-knewone-embed-options"]
      photos = JSON.parse(options)["photos"] if options

      case type
      when 'thing'
        slugs = key.split(',')
        things = Thing.any_in(slugs: slugs)
        photos = options ? photos.split(',') : Array.new(things.size, "")
        result = render partial: 'things/embed_thing', collection: things.zip(photos), locals: { klass: (slugs.size > 1) ? 'col-sm-6' : 'col-sm-12' }, as: 'embed'
      when 'list'
        list = ThingList.find key
        result = render [list], layout: browser.desktop? ? :quintet : :grid
      when 'review'
        review = Review.find key
        result = render partial: 'home/hot_review', collection: [review]
      end

      element.add_child(result)
    end
    html_doc.to_html
  end

end
