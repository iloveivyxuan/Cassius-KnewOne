class FeedPresenter < ApplicationPresenter
  presents :activity
  delegate :identifier, :reference, to: :activity

  def add_user(user)
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
    if users.present?
      users_html = render "feeds/actions/users", users: users
      action_html = render "feeds/actions/#{activity.type.to_s}"
      users_html.concat action_html
    end
  end
end
