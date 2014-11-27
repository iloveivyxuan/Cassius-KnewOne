require 'spec_helper'

describe Brand, type: :model do
  let(:thing) { create(:thing) }
  let(:brand) { Brand.create(zh_name: "福 & 八", en_name: "Foobar") }

  describe 'brand information' do
    before do
      thing.brand = brand
      thing.save
      brand.update_attributes(nickname: "test & bazinga")
    end
    specify do
      thing.reload
      expect(thing.brand_information).to include "福 & 八"
      expect(thing.brand_information).to include "test & bazinga"
    end

    specify do
      ['福 & 八', 'Foobar', 'test & bazinga'].each do |q|
        q.gsub!(/[^\u4e00-\u9fa5a-zA-Z0-9[:blank:].-_^&]+/, '')
        q = Regexp.escape(q)
        expect(Thing.search(q)).to include thing
      end
    end
  end
end
