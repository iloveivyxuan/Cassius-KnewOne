module CommentsHelper
  def comment_content(comment)
    content =  Rinku.auto_link h(comment.content)
    comment.content_users.each do |u|
      content.gsub! "@#{u.name}", link_to("@#{u.name}", u)
    end
    simple_format content
  end
end
