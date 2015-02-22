require 'spec_helper'

feature 'Sign in', slow: true do
  given(:user) { create(:user) }

  scenario 'with helper' do
    create_signed_in_user
    visit root_path
    expect(page).to have_content('安全退出')
  end
end
