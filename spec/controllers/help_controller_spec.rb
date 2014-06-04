require 'spec_helper'

describe HelpController do

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'how_to_share'" do
    it "returns http success" do
      get 'how_to_share'
      response.should be_success
    end
  end

  describe "GET 'how_to_review'" do
    it "returns http success" do
      get 'how_to_review'
      response.should be_success
    end
  end

  describe "GET 'terms'" do
    it "returns http success" do
      get 'terms'
      response.should be_success
    end
  end

  describe "GET 'knewone_for_user'" do
    it "returns http success" do
      get 'knewone_for_user'
      response.should be_success
    end
  end

  describe "GET 'knewone_for_startup'" do
    it "returns http success" do
      get 'knewone_for_startup'
      response.should be_success
    end
  end

end
