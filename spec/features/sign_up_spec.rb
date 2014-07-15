require 'spec_helper'

feature 'Sign up' do
  given(:user) { build(:user) }

  background do
    visit root_path
  end

  scenario 'with email', js: true do
    within '.landing .entry_email' do
      click_link '注册'
    end

    within '#email_sign_up_pop_up' do
      fill_in '昵称',     with: user.name
      fill_in '邮箱地址', with: user.email
      fill_in '密码',     with: user.password
      click_button '用邮箱注册'
    end

    expect(page).to have_title('欢迎')
  end
end
