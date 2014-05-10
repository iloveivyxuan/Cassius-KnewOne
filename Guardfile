guard 'livereload' do
  watch(%r{app/controllers/.+\.rb})
  watch(%r{app/views/.+\.(erb|haml|slim|jbuilder|builder)})
  watch(%r{app/helpers/.+\.rb})
  watch(%r{app/presenters/.+\.rb})
  watch(%r{public/.+\.(css|js|html)})
  watch(%r{config/locales/.+\.yml})
  # Rails Assets Pipeline
  watch(%r{(app|vendor)/assets/\w+/(.+\.(coffee|scss|hbs))})  { |m| "/assets/#{m[2]}" }
end
