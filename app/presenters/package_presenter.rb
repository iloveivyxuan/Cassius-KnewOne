# -*- coding: utf-8 -*-
class PackagePresenter < ApplicationPresenter
  presents :package

  def link_to_with_photo(size=:normal)
    link_to package.shop, target: '_blank' do
      image_tag package.photo.url(size)
    end
  end

  def title
    link_to package.title, package.shop, target: '_blank'
  end

  def price
    number_to_currency(package.price, precision: 2, unit: "¥")
  end
end
