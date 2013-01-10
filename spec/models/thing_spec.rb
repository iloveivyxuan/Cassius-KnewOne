require 'spec_helper'

describe Thing do
  before do
    @thing = Thing.new(title: "title",
                       description: "description",
                       author: Fabricate(:user))
  end

  context "need 1 photo at least" do
    subject {@thing}
    it {should_not be_valid}
  end
end
