module BrandsHelper
  def brand_filters
    {
      'things_size' => '产品数',
      'created_at' => '创建时间',
      'updated_at' => '最后更新',
      'no_description' => '无描述',
      'no_country' => '无国家'
    }
  end

  def description(brand)
    if brand.description.blank?
      "<strong style='color: red;'>（空）</strong>".html_safe
    else
      brand.description.truncate(20)
    end
  end
end
