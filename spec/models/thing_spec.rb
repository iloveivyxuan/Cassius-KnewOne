require 'spec_helper'

describe Thing do
  before do
    @thing = Thing.new(title: "title",
                       description: "description",
                       author: Fabricate(:user))
  end

end
