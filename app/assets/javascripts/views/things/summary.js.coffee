class Making.Views.ThingSummary extends Backbone.View

  events:
    "click .review_photo": "changePhoto"

  changePhoto: (e) ->
    e.preventDefault()
    $photo_main = $('figure#photo_main img')
    $photo_main.fadeOut 'slow', =>
      $photo_main.replaceWith $('<img>').attr('src', $(e.target).data('url'))
      $photo_main.fadeIn 'slow'
