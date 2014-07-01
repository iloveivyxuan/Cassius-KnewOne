do (exports = Making) ->

  exports.Models.Draft = Backbone.Model.extend
    idAttribute: 'key'
    url: ->
      return '/drafts/' + @get('key')
