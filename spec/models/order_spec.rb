require 'spec_helper'

describe Order, type: :model, slow: true do
  let(:user) { create(:user, :with_cart_items, :with_addresses) }
  let(:address) { user.addresses.unscoped.first }
  let(:items_price) { user.cart_items.map(&:price).reduce(:+) }

  let(:order) { create(:order, user: user) }
  let(:order_history) { order.order_histories.last }
  let(:trade_no)   { Faker::Number.number(10) }
  let(:deliver_no) { Faker::Number.number(10) }
  let(:payment_method) { Order::PAYMENT_METHOD.keys.sample }
  let(:note) { Faker::Lorem.sentence }

  describe '.build_order' do
    let (:order) { Order.build_order(user) }

    specify do
      expect(order.items_price).to eq items_price
      expect(order.should_pay_price).to be >= items_price
    end
  end

  context 'when use balance' do
    let(:order) { Order.build_order(user, address_id: address.id, use_balance: true) }

    context 'when balance is not enough' do
      before do
        user.recharge_balance!(0.1, '')
        order.save!
      end

      specify do
        expect(order.state).to eq :pending
        expect(order.expense_balance).to eq 0.1
        expect(user.balance).to eq 0
      end
    end

    context 'when balance is enough' do
      before do
        user.recharge_balance!(items_price + 100, '')
        order.save!
      end

      specify do
        expect(order.state).to eq :confirmed
        expect(order_history.from).to eq :freed
        expect(order_history.to).to eq :confirmed
        expect(user.balance).to eq 100 - order.deliver_price
      end
    end
  end

  describe '#confirm_payment!' do
    let(:price) { order.should_pay_price }
    let(:raw) { {trade_no: trade_no} }

    before do
      order.add_items_from_cart(user.cart_items)
      order.confirm_payment!(trade_no, price, payment_method, raw)
    end

    specify do
      expect(order.state).to eq :confirmed
      expect(order.payment_method).to eq payment_method
      expect(order.trade_no).to eq trade_no
      expect(order.trade_price).to eq price

      expect(order_history.from).to eq :pending
      expect(order_history.to).to eq :confirmed
      expect(order_history.raw).to eq raw
    end
  end

  describe '#ship!' do
    before do
      order.state = :confirmed
      order.ship!(deliver_no, note)
    end

    specify do
      expect(order.state).to eq :shipped
      expect(order.deliver_no).to eq deliver_no
      expect(order_history.from).to eq :confirmed
      expect(order_history.to).to eq :shipped
    end
  end

  describe '#cancel!' do
    before do
      order.expense_balance = 42
      order.cancel!
    end

    specify do
      expect(order.state).to eq :canceled
      expect(order_history.from).to eq :pending
      expect(order_history.to).to eq :canceled

      expect(order.expense_balance).to eq 0
      expect(user.balance).to eq 42
    end
  end

  describe '#close!' do
    before do
      order.expense_balance = 42
      order.close!
    end

    specify do
      expect(order.state).to eq :closed
      expect(order_history.from).to eq :pending
      expect(order_history.to).to eq :closed

      expect(order.expense_balance).to eq 0
      expect(user.balance).to eq 42
    end
  end

  describe '#refund!' do
    before do
      order.state = :shipped
      order.refund!
    end

    specify do
      expect(order.state).to eq :refunded_to_platform
      expect(order_history.from).to eq :shipped
      expect(order_history.to).to eq :refunded_to_platform
    end
  end

  describe '#refund_to_balance!' do
    before do
      order.state = :shipped
      order.refund_to_balance!(order.total_price)
    end

    specify do
      expect(order.state).to eq :refunded_to_balance
      expect(order_history.from).to eq :shipped
      expect(order_history.to).to eq :refunded_to_balance

      expect(order.expense_balance).to eq 0
      expect(user.balance).to eq order.total_price
    end
  end

  describe '#refunded_balance_to_platform!' do
    before do
      order.state = :shipped
      order.refund_to_balance!(order.total_price)
      order.refunded_balance_to_platform!
    end

    specify do
      expect(order.state).to eq :refunded_to_platform
      expect(order_history.from).to eq :refunded_to_balance
      expect(order_history.to).to eq :refunded_to_platform

      expect(order.expense_balance).to eq 0
      expect(user.balance).to eq 0
    end
  end

  describe '#unexpect!' do
    before do
      order.unexpect!
    end

    specify do
      expect(order.state).to eq :unexpected
      expect(order_history.from).to eq :pending
      expect(order_history.to).to eq :unexpected
    end
  end

  describe '#pay_at' do
    context "with free order" do
      before do
        order.state = :freed
      end
      specify do
        expect(order.pay_at).to be_nil
        order.confirm_free!
        order.reload
        expect(order.pay_at).to be_a DateTime
      end
    end

    context "with paid order" do
      let(:price) { order.should_pay_price }
      let(:raw) { {trade_no: trade_no} }

      specify do
        expect(order.pay_at).to be_nil
        order.confirm_payment!(trade_no, price, payment_method, raw)
        order.reload
        expect(order.pay_at).to be_a DateTime
      end
    end
  end

  describe "cleanup expired normal orders" do
    let(:user) { create(:user, :with_cart_items, :with_addresses) }
    let(:order) { create(:order, user: user) }

    specify do
      order.set(created_at: 15.minutes.ago)
      Order.cleanup_expired_orders
      expect(order.reload.state).to eq :pending
      order.set(created_at: 30.hours.ago)
      Order.cleanup_expired_orders
      expect(order.reload.state).to eq :closed
    end
  end

  describe "cleanup expired virtual orders" do
    let(:user) { create(:user, :with_cart_items, :with_addresses) }
    let(:order) { create(:order, user: user) }

    before do
      order.order_items.first.set(virtual: true)
    end

    specify do
      order.set(created_at: 15.minutes.ago)
      Order.cleanup_virtual_orders
      expect(order.reload.state).to eq :pending
      order.set(created_at: 2.hours.ago)
      Order.cleanup_virtual_orders
      expect(order.reload.state).to eq :closed
    end
  end

  describe 'could not make order after sold out' do
    let(:order) { Order.build_order(user, address_id: address.id, use_balance: true) }

    specify do
      expect(order.persisted?).to eq false
      order.order_items.first.thing.set(stage: :concept)
      expect(order.save).to eq false
      expect(order.state).to eq :pending
    end
  end

end
