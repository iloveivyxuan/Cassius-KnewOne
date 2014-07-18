require 'spec_helper'

feature 'Sign in' do
  given(:user) { create(:user) }

  background do
    visit root_path
  end

  scenario 'with email', js: true do
    within '.landing .entry_email' do
      click_link '登录'
    end

    within '#email_sign_in_pop_up' do
      fill_in '邮箱地址', with: user.email
      fill_in '密码',     with: user.password
      click_button '登录'
    end

    expect(page).to have_content('登出')
  end

  scenario 'with helper' do
    user = create_signed_in_user
    visit root_path
    expect(page).to have_content('登出')
  end
end
