require 'spec_helper'

describe Thing, :type => :model do
  let(:user) { create(:user) }
  let(:thing) { create(:thing) }

  describe '#own' do
    subject { -> { thing.own(user) } }

    it { is_expected.to change { thing.owned?(user) }.to true }
    it { is_expected.to change(thing, :owner_ids).to include user.id }
    it { is_expected.to change(user, :own_ids).to include thing.id }
    it { is_expected.to change(user, :owns_count).by 1 }
    it { is_expected.to change(user, :karma).by Settings.karma.own }
  end

  describe '#unown' do
    before do
      thing.own(user)
    end

    subject { -> { thing.unown(user) } }

    it { is_expected.to change { thing.owned?(user) }.to false }
    it { is_expected.to change(thing, :owner_ids).from include user.id }
    it { is_expected.to change(user, :own_ids).from include thing.id }
    it { is_expected.to change(user, :owns_count).by(-1) }
    it { is_expected.to change(user, :karma).by(-Settings.karma.own) }
  end

  describe '#fancy' do
    subject { -> { thing.fancy(user) } }

    it { is_expected.to change { thing.fancied?(user) }.to true }
    it { is_expected.to change(thing, :fancier_ids).to include user.id }
    it { is_expected.to change(user, :fancy_ids).to include thing.id }
    it { is_expected.to change(thing, :fanciers_count).by 1 }
    it { is_expected.to change(user, :fancies_count).by 1 }
    it { is_expected.to change(user, :karma).by Settings.karma.fancy }
  end

  describe '#unfancy' do
    before do
      thing.fancy(user)
    end

    subject { -> { thing.unfancy(user) } }

    it { is_expected.to change { thing.fancied?(user) }.to false }
    it { is_expected.to change(thing, :fancier_ids).from include user.id }
    it { is_expected.to change(user, :fancy_ids).from include thing.id }
    it { is_expected.to change(thing, :fanciers_count).by(-1) }
    it { is_expected.to change(user, :fancies_count).by(-1) }
    it { is_expected.to change(user, :karma).by(-Settings.karma.fancy) }
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
end
