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
end
