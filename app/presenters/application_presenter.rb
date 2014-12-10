class ApplicationPresenter
  def initialize(object, template=nil)
    @object = object
    @template = template
  end

  def self.presents(name)
    define_method(name) { @object }
  end

  def method_missing(*args, &block)
    @template.send(*args, &block)
  end

  def show_count(count)
    (count > 0) ? count : ""
  end

  def price_format(price, unit='￥')
    number_to_currency(price, precision: 0, unit: unit, format: '%u%n')
  end

  def login_path(path = '')
    path.present? ? path : '#'
  end
end
