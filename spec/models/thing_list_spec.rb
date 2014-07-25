require 'spec_helper'

describe ThingList, type: :model do
  let(:thing_list) { create(:thing_list) }
  let(:item) { thing_list.items.first }

  describe 'Thing#lists' do
    specify do
      expect(item.thing.lists).to include thing_list
    end
  end

  describe ThingListItem, type: :model do
    describe '#order' do
      let(:item2) { create(:thing_list_item, thing_list: thing_list) }
      let(:item3) { create(:thing_list_item, thing_list: thing_list) }

      it 'increases automatically' do
        expect(item.order).to eq 1
        expect(item2.order).to eq 2
        expect(item3.order).to eq 3
      end
    end

    context 'after thing destroy' do
      before do
        item.thing.destroy
        thing_list.reload
      end

      it 'destroys' do
        expect(thing_list.items).to_not include item
      end
    end
  end
end
