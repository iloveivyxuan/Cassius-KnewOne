require 'spec_helper'

feature 'Sign in' do
  given(:user) { create(:user) }

  background do
    visit root_path
  end

  scenario 'with email' do
    within '.landing .entry_email' do
      click_link '登录'

      within '#email_sign_in_tab' do
        fill_in '邮箱地址', with: user.email
        fill_in '密码',     with: user.password
        click_button '登录'
      end
    end

    visit root_path
    page.should have_content(user.name)
  end
end
