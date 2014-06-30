# -*- coding: utf-8 -*-
module Haven
  class UsersController < ApplicationController
    layout 'settings'

    def index
      @users ||= ::User

      if params[:name].present?
        @users = @users.where(name: /^#{Regexp.escape(params[:name])}/i)
      elsif params[:email].present?
        @users = @users.or({email: params[:email].downcase}, {unconfirmed_email: params[:email].downcase})
      elsif params[:filter]
        if params[:filter].include? 'last_thing_created_at'
          @users = @users.order_by([:last_thing_created_at, :desc])
          if params[:from].present?
            @users = @users.where(:last_thing_created_at.gte => Date.parse(params[:from]))
          end
          if params[:to].present?
            @users = @users.where(:last_thing_created_at.lt => Date.parse(params[:to]).next_day)
          end
        end
        if params[:filter].include? 'last_review_created_at'
          @users = @users.order_by([:last_review_created_at, :desc])
          if params[:from].present?
            @users = @users.where(:last_review_created_at.gte => Date.parse(params[:from]))
          end
          if params[:to].present?
            @users = @users.where(:last_review_created_at.lt => Date.parse(params[:to]).next_day)
          end
        end
        if params[:filter].include? 'last_feeling_created_at'
          @users = @users.order_by([:last_feeling_created_at, :desc])
          if params[:from].present?
            @users = @users.where(:last_feeling_created_at.gte => Date.parse(params[:from]))
          end
          if params[:to].present?
            @users = @users.where(:last_feeling_created_at.lt => Date.parse(params[:to]).next_day)
          end
        end
        if params[:filter].include? 'role'
          @users = @users.staff
        end
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
        if params[:filter].include? 'followings'
          @users = @users.where(:followings_count.gt => 0).order_by([:followings_count, :desc])
        end
        if params[:filter].include? 'followers'
          @users = @users.where(:followers_count.gt => 0).order_by([:followers_count, :desc])
        end
        if params[:filter].include? 'expense'
          @users = @users.where(:expenses_count.gt => 0).order_by([:expenses_count, :desc])
        end
        if params[:filter].include? 'unbind_email'
          @users = @users.where(:email => nil, :unconfirmed_email => nil).order_by([:created_at, :asc])
        end
        if params[:filter].include? 'created_at'
          @users = @users.order_by([:created_at, :desc])
          if params[:from].present?
            @users = @users.where(:created_at.gte => Date.parse(params[:from]))
          end
          if params[:to].present?
            @users = @users.where(:created_at.lt => Date.parse(params[:to]).next_day)
          end
        end
      else
        @users = @users.order_by([:created_at, :desc],
                                 [:things_count, :desc],
                                 [:reviews_count, :desc],
                                 [:orders_count, :desc])
      end

      @users = @users.page params[:page]

      respond_to do |format|
        format.html
        format.csv do
          lines = [%w(用户名 用户ID 分享产品 发表评测 成交订单 战斗力 邮箱 微博 Twitter 博客 网站 注册时间 最后分享产品 最后发表评测 最后发表短评 备注)]

          @users.each do |u|
            sites = u.auths.collect(&:urls).compact.reduce(&:merge) || {}
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
                u.created_at ? u.created_at : '',
                u.last_thing_created_at ? u.last_thing_created_at : '',
                u.last_review_created_at ? u.last_review_created_at : '',
                u.last_feeling_created_at ? u.last_feeling_created_at : '',
                u.admin_note
            ]
            lines<< cols
          end

          col_sep = (params[:platform] == 'numbers') ? ',' : ';'

          csv = CSV.generate :col_sep => col_sep do |csv|
            lines.each { |l| csv<< l }
          end

          if params[:platform] != 'numbers'
            send_data csv.encode 'gb2312', :replace => ''
          else
            send_data csv, :replace => ''
          end
        end
      end
    end

    def analysis
      @users ||= ::User
      case params[:find_by]
        when 'all'
        when 'reg_date'
          @users = @users.where(:created_at.lte => params[:end_date]) if params[:end_date].present?
          @users = @users.where(:created_at.gte => params[:start_date]) if params[:start_date].present?
        when 'login_date'
          @users = @users.where(:last_sign_in_at.lte => params[:end_date]) if params[:end_date].present?
          @users = @users.where(:last_sign_in_at.gte => params[:start_date]) if params[:start_date].present?
        else
      end
      if params[:filter]
        if params[:filter].include? 'role'
          @users = @users.staff
        end
        if params[:filter].include? 'login_today'
          @users = @users.where(:last_sign_in_at.gte => Date.yesterday)
        end
        if params[:filter].include? 'reg_today'
          @users = @users.where(:created_at.gte => Date.yesterday)
        end
        if params[:filter].include? 'reg_email'
          @users = @users.where(:email.ne => "")
        end
        if params[:filter].include? 'reg_weibo'
          @users = @users.where(:'auths.provider' => 'weibo')
        end
        if params[:filter].include? 'reg_qq'
          @users = @users.where(:'auths.provider' => 'qq_connect')
        end
        if params[:filter].include? 'reg_douban'
          @users = @users.where(:'auths.provider' => 'douban')
        end
        if params[:filter].include? 'reg_twitter'
          @users = @users.where(:'auths.provider' => 'twitter')
        end
      else
        @users = @users.order_by([:created_at, :desc])
      end

      @users = @users.page params[:page]

      respond_to do |format|
        format.html
        format.csv do
          lines = [%w(用户名 用户ID 邮箱 微博 Twitter 博客 网站 注册时间 最后登录)]

          @users.each do |u|
            sites = u.auths.collect(&:urls).compact.reduce(&:merge) || {}
            sites.delete "Blog" if sites["Website"] == sites["Blog"]

            cols = [
                u.name,
                u.id.to_s,
                (u.email || u.unconfirmed_email),
                sites['Weibo'],
                sites['Twitter'],
                sites['Blog'],
                sites['Website'],
                u.created_at ? u.created_at : '',
                u.last_sign_in_at ? u.last_sign_in_at : ''
            ]
            lines<< cols
          end

          col_sep = (params[:platform] == 'numbers') ? ',' : ';'

          csv = CSV.generate :col_sep => col_sep do |csv|
            lines.each { |l| csv<< l }
          end

          if params[:platform] != 'numbers'
            send_data csv.encode 'gb2312', :replace => ''
          else
            send_data csv, :replace => ''
          end
        end
      end

    end

    def show
      @user = User.find(params[:id])
    end

    def update
      user = User.find(params[:id])

      if params[:user][:identities].blank?
        params[:user][:identities] = []
      else
        params[:user][:identities].uniq!
      end

      if params[:user][:flags].blank?
        params[:user][:flags] = []
      else
        params[:user][:flags].uniq!
      end

      user.update(user_params)

      redirect_back_or haven_user_path(user)
    end

    def encourage_thing_author
      @user = User.find(params[:id])

      ThingMailer.delay.encourage_thing_author(@user)

      redirect_back_or haven_users_path
    end

    def encourage_review_author
      @user = User.find(params[:id])

      ThingMailer.delay.encourage_review_author(@user)

      redirect_back_or haven_users_path
    end

    private

    def user_params
      params.require(:user).permit!
    end
  end
end
