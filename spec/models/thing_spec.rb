require 'spec_helper'

describe Thing do
  let(:user) { create(:user) }
  let(:thing) { create(:thing) }

  describe '#own' do
    subject { -> { thing.own(user) } }

    it { should change { thing.owned?(user) }.to true }
    it { should change(thing, :owner_ids).to include user.id }
    it { should change(user, :own_ids).to include thing.id }
    it { should change(user, :owns_count).by 1 }
    it { should change(user, :karma).by Settings.karma.own }
  end

  describe '#unown' do
    before do
      thing.own(user)
    end

    subject { -> { thing.unown(user) } }

    it { should change { thing.owned?(user) }.to false }
    it { should change(thing, :owner_ids).from include user.id }
    it { should change(user, :own_ids).from include thing.id }
    it { should change(user, :owns_count).by(-1) }
    it { should change(user, :karma).by(-Settings.karma.own) }
  end

  describe '#fancy' do
    subject { -> { thing.fancy(user) } }

    it { should change { thing.fancied?(user) }.to true }
    it { should change(thing, :fancier_ids).to include user.id }
    it { should change(user, :fancy_ids).to include thing.id }
    it { should change(thing, :fanciers_count).by 1 }
    it { should change(user, :fancies_count).by 1 }
    it { should change(user, :karma).by Settings.karma.fancy }
  end

  describe '#unfancy' do
    before do
      thing.fancy(user)
    end

    subject { -> { thing.unfancy(user) } }

    it { should change { thing.fancied?(user) }.to false }
    it { should change(thing, :fancier_ids).from include user.id }
    it { should change(user, :fancy_ids).from include thing.id }
    it { should change(thing, :fanciers_count).by(-1) }
    it { should change(user, :fancies_count).by(-1) }
    it { should change(user, :karma).by(-Settings.karma.fancy) }
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
