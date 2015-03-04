module Haven
  class AdoptionsController < Haven::ApplicationController
    include AddressesHelper

    layout 'settings'

    def index
      @adoptions ||= Adoption.all

      if params[:thing]
        thing = Thing.where(title: /#{params[:thing]}/i).first
        @adoptions = @adoptions.where(:thing => thing) if thing
      end
      if params[:status]
        @adoptions = @adoptions.where(:status => params[:status].to_sym)
      end
      if params[:user]
        user = User.where(name: params[:user][:name]).first
        @adoptions = @adoptions.where(:user_id => user.id) if user
      end
      @adoptions = @adoptions.order_by [:created_at, :desc]

      respond_to do |format|
        format.html do
          @adoptions = @adoptions.page(params[:page]).per(params[:per] || 50)
        end

        format.csv do
          lines = [%w(用户名 地址 邮箱 申请理由 申请时间)]

          @adoptions.includes(:user).each do |adoption|
            cols = [
                    adoption.user.name,
                    content_for_address(adoption.address),
                    adoption.user.email,
                    adoption.note,
                    adoption.created_at.to_s
                   ]

            lines<< cols
          end

          send_csv_file lines, "领养导出 - #{Time.now}.csv", params[:platform]
        end
      end

    end

    def approve
      adoption = Adoption.find(params[:id])
      adoption.update_attributes(status: :approved)
      redirect_to :back
    end

    def deny
      adoption = Adoption.find(params[:id])
      adoption.update_attributes(status: :denied)
      redirect_to :back
    end

    def one_click_deny
      Thing.find(params[:adoption]).adoptions.each do |a|
        if a.status == :waiting
          a.status = :denied
          a.save
        end
      end
      redirect_to :back
    end
  end
end
