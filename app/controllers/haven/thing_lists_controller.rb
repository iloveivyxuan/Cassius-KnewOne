module Haven
  class ThingListsController < Haven::ApplicationController
    layout 'settings'

    def index
      @thing_lists = ::ThingList
      case params[:sort_by]
      when 'fanciers_count'
        @thing_lists = @thing_lists.desc(:fanciers_count)
        @sort_by = 'fanciers_count'
      when 'created_at'
        @thing_lists = @thing_lists.desc(:created_at)
        @sort_by = 'created_at'
      when 'updated_at'
        @thing_lists = @thing_lists.desc(:updated_at)
        @sort_by = 'updated_at'
      else
        @thing_lists = @thing_lists.hot
        @sort_by = 'heat'
      end

      @thing_lists = @thing_lists.where(description: /#{params[:description]}/i) if params[:description]

      @thing_lists = @thing_lists.page(params[:page])
    end

    def export
      @list = ThingList.find params[:id]
    end

  end
end
