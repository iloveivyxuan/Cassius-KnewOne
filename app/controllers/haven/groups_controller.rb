module Haven
  class GroupsController < Haven::ApplicationController
    layout 'settings'

    def index
      @groups = ::Group
      case params[:filter]
      when 'all'
        @groups = Group.all
      when 'approved'
        @groups = @groups.where(approved: true)
      when 'not_approved'
        @groups = @groups.ne(approved: true)
      else
        @groups = @groups.ne(approved: true)
      end
      @groups = @groups.desc(:created_at).page(params[:page]).per(20)
    end

    def approve
      @group = Group.find params[:id]
      @group.set(approved: true)
      @group.topics.set(approved: true)
      render json: { status: true }
    end
  end
end
