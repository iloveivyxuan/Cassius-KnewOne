require 'spec_helper'

describe Category, type: :model do
  let(:thing) { create(:thing) }
  let(:category) { create(:category) }
  let(:inner_c) { create(:category) }
  let(:tag) { create(:tag) }

  describe 'share same things between categories & tags' do
    before do
      category.inner_categories << inner_c
      inner_c.tags << tag
      thing.tags_text = tag.name

      refresh
      reload
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

  describe 'share tags between primary & inner categories' do
    before do
      category.inner_categories << inner_c
      inner_c.tags << tag
      thing.tags_text = tag.name

      refresh
      reload
    end

    specify do
      expect(category.tags).to include tag
      expect(inner_c.tags).to include tag
    end
  end

end

def refresh
  Category.update_thing_ids
  Category.update_things_count
  Category.update_tags
  Tag.update_things_count
end

def reload
  category.reload
  inner_c.reload
  tag.reload
end
