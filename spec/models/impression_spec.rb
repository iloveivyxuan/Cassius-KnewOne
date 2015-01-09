require 'spec_helper'

describe Impression, type: :model do
  let(:impression) { create(:impression) }
  let(:author) { impression.author }
  let(:thing) { impression.thing }
  let(:tag) { create(:tag) }

  describe 'updates User#tags and Thing#tags automatically' do
    specify do
      impression.tags << tag
      author.reload
      thing.reload

      expect(author.tags.recent.first).to eq tag
      expect(author.tags).to include tag

      impression.tags.delete(tag)
      author.reload
      thing.reload

      expect(author.tags).to_not include tag
      expect(thing.tags).to_not include tag
    end
  end
end
