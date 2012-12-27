module StepsHelper
  def link_to_add_step(f)
    step_model = Step.new
    id = step_model.id.to_s

    fields = f.simple_fields_for :steps, step_model, child_index: id do |step_fields|
      render 'step_fields', f: step_fields, i: id
    end
    nav = render 'step_nav', i: id

    link_to "+Add Step", "#", data: { id: id,
      nav: nav.gsub("\n", ""),
      fields: fields.gsub("\n", "")
    }, id: 'add_step'
  end
end
