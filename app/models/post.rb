class Post
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  include Votable
  include AutoCleanup

  field :title, type: String

  validate :title_cannot_include_reserved_words
  def title_cannot_include_reserved_words
    return if self.title.blank?

    if Blacklist.all.map(&:word).any? { |word| title.downcase.include? word }
      errors.add(:title, '名字不和谐')
    end
  end

  field :content, type: String, default: ""
  field :commented_at, type: DateTime

  belongs_to :author, class_name: "User", inverse_of: :posts, index: true

  has_many :comments
  field :comments_count, type: Integer, default: 0

  has_many :related_lotteries, class_name: "Lottery",
           inverse_of: :contributions, dependent: :delete

  has_one :entry

  index created_at: -1


  before_save :format_title
  before_save :remove_ending_blanks

  scope :since_date, ->(date) { where :created_at.gte => date }
  scope :until_date, ->(date) { where :created_at.lt => date.next_day }
  scope :recent, ->(range = 30) { gt(created_at: range.days.ago) }

  after_create :update_commented_at

  after_create do
    update_relates_counter self.author
    touch_relates_timestamp self.author
  end

  after_destroy do
    update_relates_counter self.author, -1
  end

  around_update :around_update_counter

  def update_commented_at
    update_attribute :commented_at, created_at
  end

  def cover(version = :small)
    content_photos(version).first
  end

  def content_photos(version = :small)
    self.content.scan(/<img src=\"(http:\/\/#{Settings.image_host}\/.+?)\"/).flatten.map do |src|
      src.sub(/!.*$/, "") + "!#{version}"
    end
  end

  def clean_content(version)
    block_tag = 'p, ul, ol, blockquote, pre, figure, picture, table'
    html_doc = Nokogiri::HTML::DocumentFragment.parse(content)
    if version == :wechat
      html_doc.css('.knewone-embed--thing').each do |thing|
        things = thing["data-knewone-embed-key"].split(',').map { |slug| Thing.find(slug) }
        if thing["data-knewone-embed-options"]
          photos = JSON.parse(thing["data-knewone-embed-options"])["photos"].split(",")
        end
        photos ||= Array.new(things.size, "")
        embeds = things.zip(photos).reverse
        embeds.each do |e|
          if e.last.blank?
            thing.after("<img src=#{e.first.photos.first.url}>")
          else
            thing.after("<img src=#{e.last}>")
          end
        end
      end
      html_doc.css('.knewone-embed, iframe, embed, object, video, audio').remove
      html_doc.css('h1', 'h2', 'h3', 'h4', 'h5', 'h6').each do |header|
        header.name = 'strong'
        header['style'] = 'display: block; font-size: 20px; font-weight: bold; margin: 0 0 1em 0;'
      end
      html_doc.css('img').wrap('<figure style="margin: 0 0 1em 0; text-align: center;"></figure>').each do |image|
        src = image['src']
        image['src'] = src.split('!').first.concat('!wechat') unless src.blank?
      end
      html_doc.css('div').each do |block|
        block.name = 'p'
      end
      html_doc.css(block_tag).each do |block|
        parent_node = block.parent
        parent_node.after(block) if parent_node.node_name == 'p'
      end
      html_doc.css('p').each do |p|
        p.remove if p.content.blank?
        p['style'] = 'margin: 0 0 1em 0;'
      end
    end
    html_doc.to_html.html_safe
  end

  private

  def self_changed?
    self.changed_attributes.reject { |k, v| v.nil? }.any?
  end

  def format_title
    if self.title.present?
      self.title = self.title.
        gsub(/(?<=[0-9a-z])(?=[\u4e00-\u9fa5])/i, ' ').
        gsub(/(?=[0-9a-z])(?<=[\u4e00-\u9fa5])/i, ' ').
        gsub(/\s+/, ' ')
    end
  end

  def update_relates_counter(author, step = 1)
    counter_field = :"#{model_name.plural}_count"

    if author.methods.include?(counter_field) && (author.send(counter_field) + step) >= 0
      author.inc counter_field => step
    end
  end

  def touch_relates_timestamp(author)
    timestamp_field = :"last_#{model_name.singular}_created_at"

    if author.methods.include?(timestamp_field)
      author.set timestamp_field => Time.now.to_i
    end
  end

  def change_activity_user(author)
    if a = Activity.by_type(:"new_#{model_name.singular}").by_reference(self).first
      a.user = author
      a.save
    end
  end

  def around_update_counter
    if self_changed? &&
      self.author_id_changed? &&
      self.author_id_was.present? &&
      original_author = User.find(self.author_id_was)

      yield

      if original_author != self.author
        update_relates_counter self.author
        update_relates_counter original_author, -1
        touch_relates_timestamp self.author
        change_activity_user self.author
      end
    else
      yield
    end
  end

  # remove multiple <p><br></p>
  def remove_ending_blanks
    self.content.gsub!(/(<p><br><\/p>)+\z/, "")
    self.content += "<p><br></p>" if [Review, Article, Topic].include?(self.class)
  end
end
