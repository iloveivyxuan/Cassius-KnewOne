class CustomFailure < Devise::FailureApp
  # email login not publish yet, so prevent devise redirect to login page
  def redirect_url
    root_path
  end
end
