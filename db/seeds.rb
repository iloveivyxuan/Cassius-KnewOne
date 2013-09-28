# encoding: utf-8

things = Thing.where(:stage.in => [:presell, :stock, :ship, :exclusive])
things.each do |t|
  k = t.kinds.build title: '默认', stage: t.stage
  k.price = t.price if t.price.present?

  if t.stage == :presell
    k.estimates_at = t.stage_end_at
    k.stage = :ship
  else
    t.stage = :selfrun
  end

  begin
    t.save!
  rescue Exception
    puts t.id
    puts t.errors.full_messages
    exit 1
  end
end
