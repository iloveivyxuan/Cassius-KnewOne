# -*- coding: utf-8 -*-
class CommentMessage < Message
  belongs_to :post

  class << self
    def find_by_post(user, post)
      user.messages.unread.by_type(:comment_message).where(post_id: post.id)
    end

    def read_by_post(user, post)
      find_by_post(user, post).each {|message| message.read!}
    end
  end

  private

  def find_similar
    self.class.find_by_post(user, post)
      .reject {|m| m == self}
      .first
  end
end
