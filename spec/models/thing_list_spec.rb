require 'spec_helper'

describe ThingList, type: :model do
  let(:thing_list) { create(:thing_list) }
  let(:item) { thing_list.items.first }

  describe 'Thing#lists' do
    specify do
      expect(item.thing.lists).to include thing_list
    end
  end
end
