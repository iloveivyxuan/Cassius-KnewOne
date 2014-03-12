json.type notification.type
json.content escape_javascript(send :"render_#{notification.type}_notification", notification)
