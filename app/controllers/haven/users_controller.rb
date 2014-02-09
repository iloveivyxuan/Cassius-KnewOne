module Haven
  class UsersController < ApplicationController
    layout 'settings'

    def index
      @users ||= ::User

      if params[:name].present?
        @users.where(name: /^#{name}/i)
      end

      if params[:filter]
        if params[:filter].include? 'thing'
          @users = @users.where(:things_count.gt => 0).order_by([:things_count, :desc])
        end
        if params[:filter].include? 'review'
          @users = @users.where(:reviews_count.gt => 0).order_by([:reviews_count, :desc])
        end
        if params[:filter].include? 'order'
          @users = @users.where(:orders_count.gt => 0).order_by([:orders_count, :desc])
        end
        if params[:filter].include? 'expense'
          @users = @users.where(:expenses_count.gt => 0).order_by([:expenses_count, :desc])
        end
        if params[:filter].include? 'unbind_email'
          @users = @users.where(:email => nil, :unconfirmed_email => nil).order_by([:created_at, :asc])
        end
      else
        @users = @users.order_by([:expenses_count, :desc],
                                 [:things_count, :desc],
                                 [:reviews_count, :desc],
                                 [:orders_count, :desc])
      end

      @users = @users.page params[:page]
      
      respond_to do |format|
        format.html
        format.csv do
          lines = [%w(用户名 用户ID 分享产品 发表评测 成交订单 战斗力 邮箱 微博 Twitter 博客 网站 备注)]

          @users.each do |u|
            sites = u.auths.collect(&:urls).reduce(&:merge) || {}
            sites.delete "Blog" if sites["Website"] == sites["Blog"]

            cols = [
                u.name,
                u.id.to_s,
                u.things_count,
                u.reviews_count,
                u.orders_count,
                u.expenses_count,
                (u.email || u.unconfirmed_email),
                sites['Weibo'],
                sites['Twitter'],
                sites['Blog'],
                sites['Website'],
                u.admin_note,
            ]
            lines<< cols
          end

          csv = CSV.generate :col_sep => ';' do |csv|
            lines.each { |l| csv<< l }
          end

          send_data csv.encode 'gb2312', :replace => ''
        end
      end
    end

    def show
      @user = User.find(params[:id])
    end

    def update
      user = User.find(params[:id])
      user.update(user_params)

      redirect_back_or user
    end

    private

    def user_params
      params.require(:user).permit!
    end
  end
end
