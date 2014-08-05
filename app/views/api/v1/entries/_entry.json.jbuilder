json.id entry.id.to_s
json.url api_v1_entry_url(entry)
json.html_url entry_url(entry)
json.type entry.post.model_name.singular
json.title (entry.title.present? ? entry.title : entry.post.title)
json.category_type Entry::CATEGORIES[entry.category]
json.category_type_text entry.category
json.partial! "api/v1/entries/#{entry.post.model_name.singular}", post: entry.post, entry: entry
json.created_at entry.created_at


