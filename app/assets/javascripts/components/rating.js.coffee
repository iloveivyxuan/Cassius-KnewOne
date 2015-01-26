# Rating and Score.
#

( ->
  $.fn.rating = ->
    return @each ->
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

          if $star.hasClass('selected')
            $star.removeClass('selected')
            $range.val(0)
            console.log($range)
          else
            $star.addClass('selected').siblings().removeClass('selected')
            $range.val($star.data('val'))
          $range.trigger('change')

          $star.parents('.rating').data('score', $range.val())

      score = parseInt($range.val())
      if score > 0
        $rating.find('.star').eq(-score).addClass('selected')

  $.fn.score = ->
    return @each (i, el) ->
      $self = $(el)
      score = $self.data('score')
      $stars = $()

      if $self.find('.star').length > 0 then return

      for val in [5..1]
        $star = $('<span />').addClass('star').data('val', val)
        $star.addClass('active') if $star.data('val') <= parseInt(score)
        $stars = $stars.add($star)

      $('<div />')
        .addClass('rate')
        .data('score', score)
        .append($stars)
        .appendTo($self)
)()

# Deprecated

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
