class Making.Views.Review extends Backbone.View

  tagName: 'li'
  template: JST['reviews/review']

  events:
    'click .detail': 'show'
    'click .destroy': 'destroy'
    'click .edit': 'edit'
    'submit form.update_review': 'update'

  initialize: ->
    @model.on
      change:  @render

  render: =>
    $(@el).html(@template(@model.attributes))
    this

  show: ->
    Backbone.history.navigate("reviews/#{@model.get('id')}", true)

  edit: (e) =>
    e.preventDefault()
    @$el.empty()
    $form = $('#review_form_template')
      .clone().addClass('update_review')
      .find('input').val(@model.get('title')).end()
      .find('textarea').val(@model.get('content')).end()
      .appendTo(@el).show()
    Making.Editor $form

  update: (e) =>
    e.preventDefault()
    @model.save
      title: @$('form.update_review input').val()
      content: @$('form.update_review textarea').val()
    ,
      wait: true
      success: ->
        console.log "success!"
      error: ->
        console.log "error!"


  destroy: (e) =>
    e.preventDefault()
    if confirm("您确定要删除吗?")    
      @model.destroy
        success: (model, response) =>
          @$el.fadeOut =>
            @remove()
