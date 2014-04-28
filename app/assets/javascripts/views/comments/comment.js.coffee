class Making.Views.Comment extends Backbone.View

  tagName: 'li'
  template: HandlebarsTemplates['comments/comment']

  events:
    'click .destroy': 'destroy'
    'click .reply': 'reply'

  render: =>
    @$el.html @template(@model.attributes)
    this

  destroy: (e) =>
    e.preventDefault()
    if confirm("您确定要删除吗?")
      @$el.fadeOut =>
        @remove()
      @model.destroy()

  reply: (e) =>
    e.preventDefault()
    $textarea = $('form#create_comment textarea')
    $textarea.focus()
      .val($textarea.val() + ' @' + @model.get('author').name + ' ')

