include Warden::Test::Helpers
Warden.test_mode!

def sign_in(user = create(:user))
  login_as(user, scope: :user, run_callbacks: false)
end

def sign_out
  logout(:user)
end

def create_signed_in_user
  user = create(:user)
  sign_in user
  user
end
