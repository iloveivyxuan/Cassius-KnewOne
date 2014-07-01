do (exports = Making) ->

  exports.Models.Draft = Backbone.Model.extend
    idAttribute: '_id'
    url: ->
      return '/drafts/' + @get('key')
