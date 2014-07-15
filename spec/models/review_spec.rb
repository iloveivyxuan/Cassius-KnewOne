require 'spec_helper'

describe Review, :type => :model do
  let(:review) { create(:review) }
  let(:author) { review.author }
  let(:user) { create(:user) }

  describe '#vote' do
    subject { -> { review.vote(user, true) } }

    it { is_expected.to change { review.voted?(user) }.to true }
    it { is_expected.to change(review, :lover_ids).to include user.id }
    it { is_expected.to change(review, :lovers_count).by 1 }
    it { is_expected.to change(author, :karma).by Settings.karma.post }
  end

  describe '#unvote' do
    before do
      review.vote(user, true)
    end

    subject { -> { review.unvote(user, true) } }

    it { is_expected.to change { review.voted?(user) }.to false }
    it { is_expected.to change(review, :lover_ids).from include user.id }
    it { is_expected.to change(review, :lovers_count).by(-1) }
    it { is_expected.to change(author, :karma).by(-Settings.karma.post) }
  end

  context 'when changes author' do
    let!(:original_author) { review.author.target }

    before do
      review.author = user
    end

    subject do
      lambda do
        review.save!
        original_author.reload
      end
    end

    it { is_expected.to change { original_author.reviews_count }.by(-1) }
    it { is_expected.to change { user.reviews_count }.by 1 }
  end
end
