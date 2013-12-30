module Haven
  class UsersController < ApplicationController
    layout 'settings'

    def index
      @users ||= ::User.order_by([:expenses_count, :desc], [:things_count, :desc], [:reviews_count, :desc], [:us_count, :desc])

      if params[:name].present?
        @users.where(name: /^#{name}/i)
      end

      if params[:filter]
        if params[:filter].include? 'thing'
          @users = @users.where(:things_count.gt => 0)
        end
        if params[:filter].include? 'review'
          @users = @users.where(:reviews_count.gt => 0)
        end
        if params[:filter].include? 'u'
          @users = @users.where(:us_count.gt => 0)
        end
        if params[:filter].include? 'expense'
          @users = @users.where(:expenses_count.gt => 0)
        end
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
