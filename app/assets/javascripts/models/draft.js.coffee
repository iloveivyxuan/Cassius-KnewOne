do (exports = Making) ->

  exports.Models.Draft = Backbone.Model.extend
    url: ->
      return '/drafts/' + @get('key')
