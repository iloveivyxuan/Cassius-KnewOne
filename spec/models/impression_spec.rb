require 'spec_helper'

describe Impression, type: :model do
  let(:impression) { create(:impression) }
  let(:author) { impression.author }
  let(:thing) { impression.thing }
  let(:tag) { create(:tag) }

  describe 'updates User#tags and Thing#tag_counts automatically' do
    specify do
      impression.tags << tag
      author.reload
      thing.reload

      expect(author.recent_tags(1).first).to eq tag
      expect(thing.popular_tags(2)).to include tag

      impression.tags.delete(tag)
      author.reload
      thing.reload

      expect(author.recent_tags(1)).to_not include tag
      expect(thing.popular_tags(2)).to_not include tag

      impression.tags << tag
      impression.destroy
      author.reload
      thing.reload

      expect(author.recent_tags(1)).to_not include tag
      expect(thing.popular_tags(2)).to_not include tag
    end
  end

  describe 'updates counts automatically' do
    specify do
      expect(thing.desirers_count).to eq 0
      expect(author.desires_count).to eq 0
      expect(thing.owners_count).to eq 0
      expect(author.owns_count).to eq 0

      impression.update(state: :desired)
      author.reload
      thing.reload

      expect(thing.desirers_count).to eq 1
      expect(author.desires_count).to eq 1
      expect(thing.owners_count).to eq 0
      expect(author.owns_count).to eq 0

      impression.update(state: :owned)
      author.reload
      thing.reload

      expect(thing.desirers_count).to eq 0
      expect(author.desires_count).to eq 0
      expect(thing.owners_count).to eq 1
      expect(author.owns_count).to eq 1

      impression.update(state: :none)
      author.reload
      thing.reload

      expect(thing.desirers_count).to eq 0
      expect(author.desires_count).to eq 0
      expect(thing.owners_count).to eq 0
      expect(author.owns_count).to eq 0

      impression.update(state: :owned)
      impression.destroy
      author.reload
      thing.reload

      expect(thing.desirers_count).to eq 0
      expect(author.desires_count).to eq 0
      expect(thing.owners_count).to eq 0
      expect(author.owns_count).to eq 0
    end
  end

  describe 'updates counts automatically' do
    specify do
      impression.update(fancied: false, state: :none)
      expect(impression.persisted?).to be false
    end
  end
end
