require 'spec_helper'

describe Review, type: :model do
  let(:review) { create(:review) }
  let(:author) { review.author }
  let(:user) { create(:user) }

  describe '#vote' do
    before do
      review.vote(user, true)
    end

    specify do
      expect(review.voted?(user)).to be true
      expect(review.lover_ids).to include user.id
      expect(review.lovers_count).to eq 1
    end
  end

  describe '#unvote' do
    before do
      review.vote(user, true)
      review.unvote(user, true)
    end

    specify do
      expect(review.voted?(user)).to be false
      expect(review.lover_ids).to_not include user.id
      expect(review.lovers_count).to eq 0
    end
  end

  context 'when changes author' do
    let!(:original_author) { review.author.target }

    before do
      review.author = user
      review.save!
      original_author.reload
    end

    specify do
     expect(original_author.reviews_count).to eq 0
     expect(user.reviews_count).to eq 1
    end
  end
end
