SimpleForm.setup do |config|

  config.wrappers :bootstrap, tag: :div, class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :min_max
    b.use :maxlength

    b.optional :pattern
    b.optional :readonly

    b.use :label_input
    b.use :hint, wrap_with: {tag: :span, class: 'help-block'}
    b.use :error, wrap_with: {tag: :span, class: 'help-block has-error'}
  end

  config.wrappers :horizontal, tag: :div, class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :min_max
    b.use :maxlength

    b.optional :pattern
    b.optional :readonly

    b.use :label
    b.wrapper tag: :div, class: 'controls' do |input|
      input.use :input
    end
    b.use :hint, wrap_with: {tag: :span, class: 'help-block'}
    b.use :error, wrap_with: {tag: :span, class: 'help-block has-error'}
  end

  config.wrappers :checkbox, tag: :div, class: "checkbox", error_class: "has-error" do |b|
    b.use :html5
    b.use :label_input
    b.use :hint, wrap_with: {tag: :span, class: 'help-block'}
    b.use :error, wrap_with: {tag: :span, class: 'help-block has-error'}
  end

  config.wrappers :prepend, tag: :div, class: "form-group", error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.wrapper tag: :div, class: 'input-group' do |prepend|
      prepend.use :label, wrap_with: {class: 'input-group-addon'}
      prepend.use :input
    end
    b.use :hint, wrap_with: {tag: :span, class: 'help-block'}
    b.use :error, wrap_with: {tag: :span, class: 'help-block has-error'}
  end

  config.wrappers :append, tag: :div, class: "form-group", error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.wrapper tag: :div, class: 'input-group' do |append|
      append.use :input
      append.use :label, wrap_with: {class: 'input-group-addon'}
    end
    b.use :hint, wrap_with: {tag: :span, class: 'help-block'}
    b.use :error, wrap_with: {tag: :span, class: 'help-block has-error'}
  end
end
