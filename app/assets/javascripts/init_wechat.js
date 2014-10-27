var data = {
    app: '',
    img: function() {
        var url = $('meta[name="wechat:cover_url"]').attr('content');
        if(url == '') {
            url = 'http://image.knewone.com/photos/87142c54ec6cef7d1ba8576671dd6826.jpg!small';
        }
        return url;
    },
    desc: $('meta[name="wechat:desc"]').attr('content'),
    title: function () {
        var title = $('meta[name="wechat:title"]').attr('content');
        if(title == '') {
            title = $('title').text();
        }
        return title;
    },
    link: window.location.href
};

var callback = function(res) {
    $('.js-share').fadeOut('fast');
    // 返回的是json，包含用户是否分享还是取消
};

wechat('friend', data, callback);
wechat('timeline', data, callback);
