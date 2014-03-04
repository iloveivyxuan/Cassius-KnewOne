//= require jquery
//= require bootstrap
//= require jquery.qrcode
//= require ../common

$(function() {
  var $easteregg = $('#easteregg');

  $('#social_share_wechat').popover({
    html: true,
    content: $('<div />').qrcode({render: 'image', ecLevel: 'L', text: document.URL})
  });

  $(window).on('touchmove', function() {
    if (!$easteregg.hasClass('shaking')) {
      $easteregg.addClass('shaking');
    }
  }).on('touchend', function() {
    $easteregg.removeClass('shaking');
  });
});