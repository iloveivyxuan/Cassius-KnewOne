module EntriesHelper
  def entry_title(entry)
    entry.title.present? ? entry.title : entry.post.title
  end
end
