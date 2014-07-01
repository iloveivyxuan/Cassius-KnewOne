do (exports = Making) ->

  exports.Views.Draft = Backbone.View.extend

    tagName: 'li'

    template: HandlebarsTemplates['editor/draft']

    render: ->
      @$el.html(@template(@model.attributes))

      return this

  Handlebars.registerHelper 'draft_title', ->
    return title = @[@type + '[title]']

  Handlebars.registerHelper 'draft_summary', ->
    body = $(@[@type + '[content]']).text()
    summary = ''
    if body.length > 140
      summary = body.slice(0, 140) + '......'
    else
      summary = body
    return summary

  Handlebars.registerHelper 'draft_timestamp', ->
    timestamp = new Date(@updated_at)
    return timestamp.getFullYear() + '-' + (timestamp.getMonth() + 1) +
            '-' + timestamp.getDate() + ' ' + timestamp.getHours() +
            ':' + timestamp.getMinutes() + ':' + timestamp.getSeconds()
