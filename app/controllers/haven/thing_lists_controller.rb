module Haven
  class ThingListsController < Haven::ApplicationController
    layout 'settings'

    def index
      case params[:sort_by]
      when 'fanciers_count'
        @thing_lists = ThingList.desc(:fanciers_count)
        @sort_by = 'fanciers_count'
      when 'created_at'
        @thing_lists = ThingList.desc(:created_at)
        @sort_by = 'created_at'
      when 'updated_at'
        @thing_lists = ThingList.desc(:updated_at)
        @sort_by = 'updated_at'
      else
        @thing_lists = ThingList.hot
        @sort_by = 'heat'
      end

      @thing_lists = @thing_lists.page(params[:page])
    end
  end
end
