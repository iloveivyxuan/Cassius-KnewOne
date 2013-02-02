module CommentsHelper
  def comment_content(comment)
    content =  h comment.content
    comment.content_users.each do |u|
      content.gsub! "@#{u.name}", link_to("@#{u.name}", u)
    end
    raw content
  end
end
