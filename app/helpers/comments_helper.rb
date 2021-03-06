require 'rails_rinku'

module CommentsHelper
  def comment_content(comment)
    content = auto_link comment.content, :all, target: '_blank'
    comment.content_users.each do |u|
      content.gsub! "@#{u.name}", link_to("@#{u.name}", u)
    end
    simple_format content
  end
end
