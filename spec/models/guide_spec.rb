require 'spec_helper'

describe Guide do
  before do
    @guide = Fabricate.build(:guide)
  end

  context "steps not blank" do
    before do
      @guide = Fabricate.build(:guide, steps: [])
    end

    subject {@guide}
    it {should_not be_valid}
  end
end
