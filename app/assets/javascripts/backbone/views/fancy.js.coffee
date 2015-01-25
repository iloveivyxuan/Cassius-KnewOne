class Making.Views.FancyModal extends Backbone.Marionette.ItemView
  id: 'fancy_modal'
  className: 'modal fade'
  template: HandlebarsTemplates['fancy/modal']

  ui: {
  }

  events: {
  }

  modelEvents: {
    change: 'render'
  }

  initialize: ->

  onShow: ->
    @$el.modal('show')
