//= require jquery
//= require bootstrap
//= require jquery.qrcode
//= require ../common

$(function() {
  $('#social_share_wechat').popover({
    html: true,
    content: $('<div />').qrcode({render: 'image', ecLevel: 'L', text: document.URL})
  });
});