# -*- coding: utf-8 -*-
class PackagePresenter < ApplicationPresenter
  presents :package
  delegate :title, to: :package

  def buy(index)
    link_to buy_package_thing_path(package.thing, index: index),
    target: '_blank', class: "track_event",
    data: {action: "buy", category: "thing_packages",
      label: package.thing.title+'-'+title} do
      yield
    end
  end

  def photo(size=:normal)
    image_tag package.photo.url(size)
  end

  def price
    number_to_currency(package.price, precision: 2, unit: "¥")
  end
end
