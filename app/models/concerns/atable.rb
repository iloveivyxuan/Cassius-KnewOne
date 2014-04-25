module Atable
  extend ActiveSupport::Concern

  def content_users
    @content_users ||= User.in(name: find_content_users).to_a
  end

  def find_content_users
    content.scan(/@(\S{2,20})/).flatten
  end
end
