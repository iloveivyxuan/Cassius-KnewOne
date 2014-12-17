module MerchantsHelper
  def type_value(merchant)
    return '脚本' unless merchant
    if merchant.customer_service_type == 'script'
      '脚本'
    else
      '链接'
    end
  end

  def merchant_service_type(merchant)
    return 'script' unless merchant
    merchant.customer_service_type
  end

  def placeholder(type='script')
    if type == "script"
      '格式：<script async="true" src="https://s.meiqia.com/js/mechat.js?unitid=4075"></script>'
    else
      "格式：http://bong.cn/service"
    end
  end

  def customer_service_value(merchant)
    return "" unless merchant
    merchant.customer_service
  end
end
