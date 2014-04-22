class FeedPresenter < ApplicationPresenter
  presents :activity
  delegate :identifier, :reference, to: :activity

  def merge_user(user)
    @users ||= []
    @users << user unless @users.include? user
  end

  def users
    @users || []
  end

  def render_to_html
    render "feeds/#{activity.type.to_s.split('_').last}", fp: self
  end

  def render_action
    render "feeds/actions/#{activity.type.to_s}", fp: self
  end

  def render_users
    render 'feeds/actions/users', up: present(activity.user)
  end
end
