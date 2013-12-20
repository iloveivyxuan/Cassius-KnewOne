require "spec_helper"

describe LandingPagesController do
  describe "routing" do

    it "routes to #index" do
      get("/landing_pages").should route_to("landing_pages#index")
    end

    it "routes to #new" do
      get("/landing_pages/new").should route_to("landing_pages#new")
    end

    it "routes to #show" do
      get("/landing_pages/1").should route_to("landing_pages#show", :id => "1")
    end

    it "routes to #edit" do
      get("/landing_pages/1/edit").should route_to("landing_pages#edit", :id => "1")
    end

    it "routes to #create" do
      post("/landing_pages").should route_to("landing_pages#create")
    end

    it "routes to #update" do
      put("/landing_pages/1").should route_to("landing_pages#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/landing_pages/1").should route_to("landing_pages#destroy", :id => "1")
    end

  end
end
