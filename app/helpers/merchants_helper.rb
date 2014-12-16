module MerchantsHelper
  def type_value(merchant)
    return '脚本' unless merchant
    if merchant.customer_service_type == 'script'
      '脚本'
    else
      '链接'
    end
  end
end
