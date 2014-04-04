module UserRoutesHelper
  def user_url_for(user, action, options = {})
    if user.personal_domain.present?
      base = "//#{user.personal_domain}.#{request.domain}#{request.port_string}/#{action}"
      if options.empty?
        base
      else
        "#{base}?#{options.to_param}"
      end
    else
      url_for({controller: '/users', action: action, id: user.id.to_s, subdomain: false}.merge(options))
    end
  end

  %i(owns fancies things reviews topics groups activities).each do |action|
    class_eval <<-EVAL
      def #{action}_user_url(user, options = {})
        user_url_for(user, :#{action}, options)
      end
    EVAL
  end

  def user_url(user, options = {})
    if user.personal_domain.present?
      base = "//#{user.personal_domain}.#{request.domain}#{request.port_string}"
      if options.empty?
        base
      else
        "#{base}?#{options.to_param}"
      end
    else
      url_for({controller: '/users', id: user.id.to_s, subdomain: false}.merge(options))
    end
  end
end
