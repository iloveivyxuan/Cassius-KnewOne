require 'spec_helper'

feature 'Walk around (Smoke test)', slow: true do
  given!(:user) { create(:user, :with_addresses, :with_invoices) }
  given!(:thing) { create(:thing, :for_sell, author: user) }
  given!(:order) { create(:order, user: user) }
  given!(:review) { create(:review, author: user, thing: thing) }
  given!(:feeling) { create(:feeling, author: user, thing: thing) }
  given!(:story) { create(:story, author: user, thing: thing) }
  given!(:group) { create(:group, :with_members) }
  given!(:topic) { create(:topic, author: user, group: group) }
  given!(:notification) { create(:notification, receiver: user) }
  given!(:dialog) { create(:dialog, sender: user) }
  given!(:paths) do
    [
     root_path,
     welcome_path,
     # maps
     maps_things_path,
     maps_reviews_path,
     maps_topics_path,
     maps_groups_path,
     maps_categories_path,
     maps_entries_path,
     # help
     help_path,
     help_how_to_share_path,
     help_how_to_review_path,
     help_terms_path,
     help_knewone_for_user_path,
     help_knewone_for_startup_path,
     # devise
     new_user_session_path,
     edit_user_password_path,
     cancel_user_registration_path,
     new_user_registration_path,
     edit_user_registration_path,
     new_user_confirmation_path,
     # settings
     setting_root_path,
     edit_profile_path,
     edit_account_path,
     addresses_path,
     new_address_path,
     edit_address_path(user.addresses.first),
     invoices_path,
     new_invoice_path,
     edit_invoice_path(user.invoices.first),
     balances_path,
     coupons_path,
     edit_notification_settings_path,
     # explore
     explore_path,
     explore_features_path,
     explore_reviews_path,
     explore_specials_path,
     explore_events_path,
     # users
     fancies_user_path(user),
     owns_user_path(user),
     reviews_user_path(user),
     feelings_user_path(user),
     things_user_path(user),
     groups_user_path(user),
     topics_user_path(user),
     activities_user_path(user),
     followings_user_path(user),
     followers_user_path(user),
     profile_user_path(user),
     user_path(user),
     # cart items
     cart_items_path,
     # orders
     tenpay_notify_order_path(order),
     tenpay_callback_order_path(order),
     alipay_callback_order_path(order),
     deliver_bill_order_path(order),
     orders_path,
     new_order_path,
     order_path(order),
     # recommend users
     recommend_users_profile_path,
     # things
     things_path,
     edit_thing_path(thing),
     thing_path(thing),
     random_things_path,
     category_things_path(thing.categories.first),
     buy_thing_path(thing),
     comments_thing_path(thing),
     related_thing_path(thing),
     groups_thing_path(thing),
     # thing reviews
     thing_reviews_path(thing),
     new_thing_review_path(thing),
     edit_thing_review_path(thing, review),
     thing_review_path(thing, review),
     # thing feelings
     thing_feelings_path(thing),
     thing_feeling_path(thing, feeling),
     # thing stories
     thing_stories_path(thing),
     new_thing_story_path(thing),
     edit_thing_story_path(thing, story),
     thing_story_path(thing, story),
     # categories
     all_categories_path,
     categories_path,
     # groups
     all_groups_path,
     members_group_path(group),
     fancies_group_path(group),
     new_group_topic_path(group),
     edit_group_topic_path(group, topic),
     group_topic_path(group, topic),
     groups_path,
     new_group_path,
     edit_group_path(group),
     group_path(group),
     # notifications
     notifications_path,
     # dialogs
     dialogs_path,
     dialog_path(dialog),
     # rewards
     rewards_path,
     # specials
     valentine_path,
     womensday_path,
     makerfaire_path
    ]
  end

  def visit_all_paths_as(role)
    unless role == :guest
      user.role = role
      user.save!
      sign_in user
    end

    debug = false
    paths.each do |path|
      puts path if debug
      visit path
    end
  end

  scenario 'as guest' do
    visit_all_paths_as :guest
  end

  scenario 'as normal user' do
    visit_all_paths_as ''
  end

  scenario 'as editor' do
    visit_all_paths_as :editor
  end

  scenario 'as sale' do
    visit_all_paths_as :sale
  end

  scenario 'as admin' do
    visit_all_paths_as :admin
  end
end
