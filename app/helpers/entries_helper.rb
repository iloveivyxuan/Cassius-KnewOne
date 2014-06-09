module EntriesHelper

  def entry_title(entry)
    entry.title.present? ? entry.title : entry.post.title
  end

  def active_nav_tab(entry)
    provide :nav, Entry::CATEGORIES[entry.category]
  end
end
