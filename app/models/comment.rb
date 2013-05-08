class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  field :content, type: String

  embedded_in :post
  belongs_to :author, class_name: 'User'

  validates :content, presence: true, length: {maximum: 300}

  default_scope desc(:created_at)

  after_create :notify_related_users
  after_create :update_commented_at
  after_destroy :update_commented_at

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

  def update_commented_at
    post.reload
    if post.comments.present?
      post.update_attribute :commented_at, post.comments.first.created_at
    else
      post.update_attribute :commented_at, post.created_at
    end
  end
end
