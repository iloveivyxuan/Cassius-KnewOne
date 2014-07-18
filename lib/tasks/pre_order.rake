desc "pre order"
task :pre_order do |t, args|
  t = Thing.find('bo-tai-ivoka-mini-x-mi-ni-zhi-neng-xing-che-xi-tong')
  k = t.kinds.first
  orders = Order.by_thing_kind(k).limit(50)
  total_size = orders.size

  k.stock = total_size
  k.save!

  orders.each_with_index do |o, i|
    u = o.user

    o1 = u.orders.build
    o1.address = o.address
    o1.deliver_by = o.deliver_by
    o1.system_note = "由订单#{o.order_no}生成"
    o1.valid_period_days = 3
    o1.note = o.note
    o1.admin_note = o.admin_note
    o1.order_items.build({
                             thing_title: t.title,
                             kind_title: k.title,
                             quantity: 1,
                             thing: t,
                             kind_id: k.id,
                             single_price: k.price
                         })
    o1.save!

    ThingMailer.preorder(o1, t, u).deliver

    puts "[#{i+1}/#{total_size}] #{o.user.name} #{o1.order_no}"
  end
end
