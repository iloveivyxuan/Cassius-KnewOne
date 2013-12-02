class WayBillWorker
  include Sidekiq::Worker

  PATH = Rails.root.join('tmp')

  def perform(order_id)
    order = Order.find(order_id)
    generator = case order.deliver_by
                  when :sf then
                    SfWayBill.new
                  when :zt then
                    ZtoWayBill.new
                end
    File.open(PATH.join("waybill_#{order.id.to_s}.gif"), 'wb+') do |f|
      f.write(generator.draw_body_from_order(order).to_io_stream)
    end
  end
end
