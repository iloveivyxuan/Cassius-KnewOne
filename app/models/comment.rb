class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  field :content, type: String

  embedded_in :post
  belongs_to :author, class_name: 'User'

  validates :content, presence: true, length: {maximum: 255}

  default_scope desc(:created_at)

  after_create :notify_related_users

  def content_users
    names = content.scan(/@(\S{2,20})/).flatten
    User.in(name: names).to_a
  end

  private

  def related_users
    content_users
      .push(post.author)
      .reject {|user| !user || user == author}
      .uniq
  end

  def notify_related_users
    author.send_message related_users, CommentMessage.new(post: post)
  end
end
