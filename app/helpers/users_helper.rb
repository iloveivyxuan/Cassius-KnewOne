module UsersHelper
  def provider_link(user)
    auth = user.auths.first
    link_to auth.name, auth.url
  end
end
