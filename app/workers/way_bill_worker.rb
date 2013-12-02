class WayBillWorker
  include Sidekiq::Worker

  PATH = Rails.root.join('tmp')

  def perform(order_id)
    order = Order.find(order_id)

    return unless order.waybill.url.nil?

    generator = case order.deliver_by
                  when :sf then
                    ::SfWayBill.new
                  when :zt then
                    ::ZtoWayBill.new
                  when :sf_hongkong then
                    ::SfWayBill.new
                end
    tmp = Tempfile.new ["waybill_#{order.id.to_s}", '.gif'], [tmpdir = Dir.tmpdir], :encoding => 'ascii-8bit'
    tmp.write generator.draw_body_from_order(order).to_io_stream
    order.waybill.store! tmp

    order.save
    tmp.close
  end
end
