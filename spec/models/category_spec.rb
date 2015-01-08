require 'spec_helper'

describe Category, type: :model do
  let(:thing) { create(:thing) }
  let(:category) { create(:category) }
  let(:category2) { create(:category, parent: category) }
  let(:category3) { create(:category, parent: category2) }

  specify do
    thing.categories << category3
    thing.reload

    expect(thing.categories).to include category
    expect(thing.categories).to include category2
    expect(thing.categories).to include category3

    thing.categories.delete(category3)
    thing.reload

    expect(thing.categories.size).to eq 0
  end
end
