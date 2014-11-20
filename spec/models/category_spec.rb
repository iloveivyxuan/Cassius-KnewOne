require 'spec_helper'

describe Category, type: :model do

  describe 'things & categories & tags' do
    let(:thing) { create(:thing) }
    let(:category) { create(:category) }
    let(:inner_c) { create(:category) }
    let(:tag) { create(:tag) }

    before do
      category.inner_categories << inner_c
      inner_c.tags << tag
      thing.tags_text = tag.name

      # refresh
      Category.update_thing_ids
      Category.update_things_count
      Tag.update_things_count

      # reload
      category.reload
      inner_c.reload
      tag.reload
    end

    specify do
      expect(category.things).to include thing
      expect(inner_c.things).to include thing
      expect(tag.things).to include thing
      expect(category.things_count).to eq 1
      expect(inner_c.things_count).to eq 1
      expect(tag.things_count).to eq 1

      expect(thing.categories.sort).to eq [category, inner_c].map(&:name).sort
      expect(thing.tags).to include tag
    end
  end

end
