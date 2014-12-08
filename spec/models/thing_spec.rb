require 'spec_helper'

describe Thing, type: :model do
  let(:user) { create(:user) }
  let(:thing) { create(:thing) }

  describe '#own' do
    before do
      thing.own(user)
    end

    specify do
      expect(thing.owned?(user)).to be true
      expect(thing.owner_ids).to include user.id
      expect(user.own_ids).to include thing.id
      expect(user.owns_count).to eq 1
    end
  end

  describe '#unown' do
    before do
      thing.own(user)
      thing.unown(user)
    end

    specify do
      expect(thing.owned?(user)).to be false
      expect(thing.owner_ids).to_not include user.id
      expect(user.own_ids).to_not include thing.id
      expect(user.owns_count).to eq 0
    end
  end

  describe '#fancy' do
    before do
      thing.fancy(user)
    end

    specify do
      expect(thing.fancied?(user)).to be true
      expect(thing.fancier_ids).to include user.id
      expect(user.fancy_ids).to include thing.id
      expect(thing.fanciers_count).to eq 1
      expect(user.fancies_count).to eq 1
    end
  end

  describe '#unfancy' do
    before do
      thing.fancy(user)
      thing.unfancy(user)
    end

    specify do
      expect(thing.fancied?(user)).to be false
      expect(thing.fancier_ids).to_not include user.id
      expect(user.fancy_ids).to_not include thing.id
      expect(thing.fanciers_count).to eq 0
      expect(user.fancies_count).to eq 0
    end
  end

  describe '#related_things' do
    let(:thing2) { create(:thing, categories: thing.categories) }

    before do
      thing.fancy(user)
      thing.own(user)
      thing2.fancy(user)
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
