module EntriesHelper

  def entry_title(entry)
    entry.title.present? ? entry.title : entry.post.title
  end

  def entry_cover(entry, size=:middle)
    if entry.category == '专题' && entry.cover.present?
      entry.cover.url(size)
    else
      case entry.cover_img
      when :cover
        entry.cover.url(size)
      when :canopy
        if entry.canopy.present?
          entry.canopy.url(size)
        else
          "http://image.knewone.com/photos/881180dea7302c0a0fd05717e5397eba.jpg!#{size}"
        end
      else
        "http://image.knewone.com/photos/881180dea7302c0a0fd05717e5397eba.jpg!#{size}"
      end
    end
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

end
