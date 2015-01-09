require 'spec_helper'

describe Impression, type: :model do
  let(:impression) { create(:impression) }
  let(:author) { impression.author }
  let(:tag) { create(:tag) }

  describe 'updates User#tags automatically' do
    specify do
      impression.tags << tag
      author.reload

      expect(author.tags.recent.first).to eq tag

      impression.tags.delete(tag)
      author.reload

      expect(author.tags).to_not include tag
    end
  end
end
