require 'spec_helper'

describe Notification, type: :model do
  let(:feeling) { create(:feeling) }
  let(:receiver) { create(:user) }
  let(:sender) { create(:user) }

  describe 'notification settings control' do
    specify do
      expect(receiver.notifications.size).to eq 0
      receiver.notify :love_feeling, context: feeling, sender: sender
      expect(receiver.reload.notifications.size).to eq 1

      receiver.notification_setting[:love_feeling] = :none
      receiver.notifications.clear
      receiver.save
      expect(receiver.reload.notifications.size).to eq 0
      receiver.notify :love_feeling, context: feeling, sender: sender
      expect(receiver.reload.notifications.size).to eq 0
    end
  end
end
