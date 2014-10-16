module Haven
  class ResourcesController < Haven::ApplicationController
    layout 'settings'
    before_action :set_resource, only: [:show, :edit, :update, :destroy]

    def new
    end

    def index
      @resources = Resource.all
      if params[:resource_name]
        @resources = @resources.where(name: params[:resource_name])
      end
      @resources = @resources.page(params[:page]).per(20)
    end

    def show
    end

    def edit
    end

    def create
      @resource = Resource.new(resource_params)
      @resource.save
      redirect_to haven_resources_path
    end

    def update
      @resource.update_attributes(resource_params)
      redirect_to haven_resources_path
    end

    def destroy
      @resource.destroy
      redirect_to haven_resources_path
    end

    private

    def set_resource
      @resource = Resource.find params[:id]
    end

    def resource_params
      params.require(:resource).permit!
    end

  end
end
