//= require jquery
//= require bootstrap
//= require jquery.qrcode
//= require jquery.fittext
//= require ../common

$(function () {
  $(".pageTitle").fitText(2, { minFontSize: '20px'});
  $('#social_share_wechat').popover({
    html: true,
    content: $('<div />').qrcode({
      render: 'image',
      ecLevel: 'L',
      text: document.URL
    })
  });
});
