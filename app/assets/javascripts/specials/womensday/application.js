//= require jquery
//= require bootstrap
//= require jquery.qrcode
//= require ../common

$(function() {
  $('.qr-field').qrcode({render: 'image', ecLevel: 'L', text: document.URL});
});