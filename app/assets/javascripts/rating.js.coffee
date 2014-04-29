Making.Rating = ->
  rateize = ->
    $range = $(@)
    $stars = $()
    for val in [parseInt($range.attr('max'))..1]
      $stars = $stars.add($('<span />').addClass('star').data('val', val))

    $rating = $('<div />')
      .addClass('rating')
      .append($stars)
      .insertAfter($range)
      .data('score', $range.val())
      .on 'click', '.star', ->
        $star = $(@)
        $star.addClass('selected').siblings().removeClass('selected')
        $range.val($star.data('val'))
        $star.parents('.rating').data('score', $range.val())

    score = parseInt($range.val())
    if score > 0
      $rating.find('.star').eq(-score).addClass('selected')

  $ ->
    $('[type="range"].range_rating').each rateize
