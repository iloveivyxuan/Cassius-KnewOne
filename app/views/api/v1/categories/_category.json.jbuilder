json.url url_wrapper(category)
json.html_url things_url(category: category)
json.things_url url_wrapper(category, :things)
json.name category.name
json.things_count category.things_count
