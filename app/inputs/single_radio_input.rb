class SingleRadioInput < SimpleForm::Inputs::Base
  def input
    input_html_options[:disabled] = input_html_options[:disabled].to_s if input_html_options[:disabled]
    @builder.radio_button(attribute_name, options.delete(:value), input_html_options)
  end

  def label_input
    options[:label] ? input + label : input
  end
end
