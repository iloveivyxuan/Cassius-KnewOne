require 'spec_helper'

describe User, type: :model do
  let(:user) { create(:user) }

  describe 'Relationship' do
    let(:user2) { create(:user) }

    specify do
      expect(user.followed?(user2)).to be false
      expect(user2.followed?(user)).to be false
      expect(user.followings_count).to eq 0
      expect(user.followers_count).to eq 0
      expect(user2.followings_count).to eq 0
      expect(user2.followers_count).to eq 0

      user.follow(user2)

      expect(user.followed?(user2)).to be true
      expect(user2.followed?(user)).to be false
      expect(user.followings_count).to eq 1
      expect(user.followers_count).to eq 0
      expect(user2.followings_count).to eq 0
      expect(user2.followers_count).to eq 1

      user.unfollow(user2)

      expect(user.followed?(user2)).to be false
      expect(user2.followed?(user)).to be false
      expect(user.followings_count).to eq 0
      expect(user.followers_count).to eq 0
      expect(user2.followings_count).to eq 0
      expect(user2.followers_count).to eq 0
    end
  end

  describe 'Cart' do
    let(:cart_item) { build(:cart_item) }

    describe '#add_to_cart' do
      before do
        user.add_to_cart(cart_item.attributes.symbolize_keys)
        user.add_to_cart(cart_item.attributes.symbolize_keys)
      end

      specify do
        expect(user.cart_items.size).to eq 1
        expect(user.cart_items.first.thing_id).to eq cart_item.thing_id
        expect(user.cart_items.first.kind_id).to eq cart_item.kind_id
        expect(user.cart_items.first.quantity).to eq 2 * cart_item.quantity
      end
    end
  end

  describe 'Balance' do
    let(:order) { create(:order) }
    let(:value) { BigDecimal(Faker::Commerce.price, 2) }
    let(:note) { Faker::Lorem.sentence }
    let(:last_log) { user.balance_logs.last }

    it 'has no balance when created' do
      expect(user.balance).to eq 0
      expect(user.has_balance?).to be false
    end

    describe '#recharge_balance!' do
      before do
        user.recharge_balance!(value, note)
      end

      specify do
        expect(user.balance).to eq value

        expect(last_log).to be_a(DepositBalanceLog)
        expect(last_log.value).to eq value
        expect(last_log.note).to eq note
      end
    end

    describe '#refund_to_balance!' do
      before do
        user.refund_to_balance!(order, value, note)
      end

      specify do
        expect(user.balance).to eq value

        expect(last_log).to be_a(RefundBalanceLog)
        expect(last_log.order).to eq order
        expect(last_log.value).to eq value
        expect(last_log.note).to eq note
      end
    end

    describe '#revoke_refund_to_balance!' do
      before do
        user.recharge_balance!(value, note)
      end

      context 'when balance not enough' do
        subject do
          user.revoke_refund_to_balance!(order, user.balance + 0.01, note)
        end

        it { is_expected.to be false }
      end

      context 'when balance enough' do
        before do
          user.revoke_refund_to_balance!(order, value, note)
        end

        specify do
          expect(user.balance).to eq 0

          expect(last_log).to be_a(RevokeRefundBalanceLog)
          expect(last_log.order).to eq order
          expect(last_log.value).to eq value
          expect(last_log.note).to eq note
        end
      end
    end

    describe '#expense_balance!' do
      before do
        user.recharge_balance!(value, note)
      end

      context 'when balance not enough' do
        subject do
          user.expense_balance!(user.balance + 0.01, note)
        end

        it { is_expected.to be false }
      end

      context 'when balance enough' do
        before do
          user.expense_balance!(value, note)
        end

        specify do
          expect(user.balance).to eq 0

          expect(last_log).to be_an(ExpenseBalanceLog)
          expect(last_log.value).to eq value
          expect(last_log.note).to eq note
        end
      end
    end
  end
end
