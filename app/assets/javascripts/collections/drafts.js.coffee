do (exports = Making) ->

  exports.Collections.Drafts = Backbone.Collection.extend
    model: exports.Models.Draft
    url: '/drafts/'
