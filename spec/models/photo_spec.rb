require 'spec_helper'

describe Photo do
  before do
    @photo = Fabricate(:photo)
  end

  subject {@photo}

  it {should be_valid}
  its(:image_url) {should =~ Regexp.new(Settings.upyun.photo_bucket_domain)}
  its(:name) {should == "example.png"}
  its(:size) {should == 1479}

end
