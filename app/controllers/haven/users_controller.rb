module Haven
  class UsersController < Haven::ApplicationController
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
        if params[:filter].include? 'adoption'
          @users = @users.where(:adoptions_count.gt => 0)
        end
        if params[:filter].include? 'recommend'
          @users = @users.where(:recommend_priority.gt => 0).order_by([:recommend_priority, :desc])
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
      elsif params[:search]
        q = params[:search]
        @users = User.or({ id: q }, { name: /#{q}/i }, { email: /#{q}/i }, { unconfirmed_email: /#{q}/i })
      else
        @users = @users.order_by([:created_at, :desc],
                                 [:things_count, :desc],
                                 [:reviews_count, :desc],
                                 [:orders_count, :desc])
      end

      respond_to do |format|
        format.html do
          @users = @users.page params[:page]
        end
        format.csv do
          lines = [%w(用户名 用户ID 分享产品 发表评测 成交订单 战斗力 邮箱 微博 Twitter 博客 网站 注册时间 备注)]

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

    def batch_show
      @users = params[:names].lines.reduce([]) do |users, line|
        user = User.where(name: line.chomp).first
        users << user if user.present?
        users
      end
    end

    def confirm_email
      user = User.find params[:id]
      unless user.confirmed?
        user.confirm!
      end
      redirect_to :back
    end

    def reset_password
      @user = User.find params[:id]
      flash[:token] = @user.send_reset_password_instructions
      redirect_to :back
    end

    def fuck_you
      @user = User.find params[:id]
      @user.set(status: :blocked)
      @user.activities.update_all(visible: false)
      @user.notifications.clear
      @user.things.delete_all
      @user.topics.delete_all
      @user.reviews.delete_all
      @user.feelings.delete_all
      @user.thing_lists.delete_all
      redirect_to :back
    end

    def batch_query
    end

    private

    def user_params
      params.require(:user).permit!
    end
  end
end
