require 'spec_helper'

describe Entry, type: :model do
  context "#index" do
    it "display in right page" do
      (1..36).to_a.reverse.each do |ch|
        Entry.create(title: ch, published: true, category: "专访", external_link: "foo")
      end
      all = Entry.published.not.in(category: %w(活动 特写)).desc(:created_at)

      expect(all.page(nil).per(11).offset(0).pluck(:title).map(&:to_i).sort).to eq (1..11).to_a.sort
      expect(all.page(1).per(11).offset(0).pluck(:title).map(&:to_i).sort).to eq (1..11).to_a.sort
      expect(all.page(2).per(12).offset(11).pluck(:title).map(&:to_i).sort).to eq (12..23).to_a.sort
      expect(all.page(3).per(12).offset(23).pluck(:title).map(&:to_i).sort).to eq (24..35).to_a.sort
      expect(all.page(4).per(12).offset(35).pluck(:title).map(&:to_i).sort).to eq [36]
    end
  end
end
