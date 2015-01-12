require 'spec_helper'

describe Thing, type: :model do
  let(:user) { create(:user) }
  let(:thing) { create(:thing) }

  describe '#fancy and #unfancy' do
    specify do
      expect(thing.fancied?(user)).to be false

      thing.fancy(user)
      thing.reload
      user.reload

      expect(thing.fancied?(user)).to be true
      expect(thing.fanciers_count).to eq 1
      expect(user.fancies_count).to eq 1

      thing.unfancy(user)
      thing.reload
      user.reload

      expect(thing.fancied?(user)).to be false
      expect(thing.fanciers_count).to eq 0
      expect(user.fancies_count).to eq 0
    end
  end

  describe '#desire and #undesire' do
    specify do
      expect(thing.desired?(user)).to be false

      thing.desire(user)
      thing.reload
      user.reload

      expect(thing.fancied?(user)).to be true
      expect(thing.desired?(user)).to be true
      expect(thing.desirers_count).to eq 1
      expect(user.desires_count).to eq 1

      thing.undesire(user)
      thing.reload
      user.reload

      expect(thing.fancied?(user)).to be true
      expect(thing.desired?(user)).to be false
      expect(thing.desirers_count).to eq 0
      expect(user.desires_count).to eq 0
    end
  end

  describe '#own and #unown' do
    specify do
      expect(thing.owned?(user)).to be false

      thing.own(user)
      thing.reload
      user.reload

      expect(thing.fancied?(user)).to be true
      expect(thing.owned?(user)).to be true
      expect(thing.owners_count).to eq 1
      expect(user.owns_count).to eq 1

      thing.unown(user)
      thing.reload
      user.reload

      expect(thing.fancied?(user)).to be true
      expect(thing.owned?(user)).to be false
      expect(thing.owners_count).to eq 0
      expect(user.owns_count).to eq 0
    end
  end

  describe '#related_things' do
    let(:thing2) { create(:thing, categories: thing.categories) }

    before do
      thing.own(user)
      thing2.own(user)

      Thing.recal_all_related_things
      thing.reload
      thing2.reload
    end

    specify do
      expect(thing.related_things).to include thing2
      expect(thing2.related_things).to include thing
    end
  end

  describe '#brand' do
    let(:thing) { create(:thing) }
    let(:thing2) { create(:thing) }
    let(:brand) { Brand.create(zh_name: "测试", en_name: "Test", country: 'CN') }
    let(:brand2) { Brand.create(zh_name: "不存在", en_name: "not_exists", country: 'CN') }

    before do
      thing.brand_text = brand.en_name
      thing2.brand_text = brand2.en_name
      thing.save; thing2.save
      Brand.update_things_brand_name
      thing2.brand_text = ""
      thing2.save
      Brand.update_things_brand_name
      thing.reload
      thing2.reload
    end

    specify do
      expect(thing.brand_name).to eq brand.brand_text
      expect(thing2.brand_name).to eq ''
    end
  end

  describe '#stage' do
    let(:thing) { create(:thing) }

    context 'set stage & price_unit' do
      before do
        thing.set(stage: :concept)
        thing.reload
      end
      it 'concept to domestic' do
        thing.shop = Faker::Internet.url
        thing.price_unit = "¥"
        thing.save

        expect(thing.stage).to eq :domestic
      end

      it 'concept to abroad' do
        thing.shop = Faker::Internet.url
        thing.price_unit = "$"
        thing.save

        expect(thing.stage).to eq :abroad
      end

      it 'not changed' do
        thing.shop = Faker::Internet.url
        thing.price_unit = "$"
        thing.save

        expect(thing.stage).to eq :abroad

        thing.price_unit = "¥"
        thing.save

        expect(thing.stage).to eq :abroad
      end

      it 'kick' do
        thing.shop = "http://kickstarter.com/foobar"
        thing.price_unit = "$"
        thing.save

        expect(thing.stage).to eq :kick
      end
    end
  end
end
