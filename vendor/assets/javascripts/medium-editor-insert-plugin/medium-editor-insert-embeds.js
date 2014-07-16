/*!
 * medium-editor-insert-plugin v0.2.4 - jQuery insert plugin for MediumEditor
 *
 * Embeds Addon
 *
 * https://github.com/orthes/medium-editor-insert-plugin
 *
 * Copyright (c) 2014 Vexus2 (https://github.com/vexus2)
 * Released under the MIT license
 */

(function ($) {

  $.fn.mediumInsert.registerAddon('embeds', {

    /**
     * Embeds initial function
     * @return {void}
     */
    init : function () {
      this.$el = $.fn.mediumInsert.insert.$el;
      this.setEmbedButtonEvents();
      this.preparePreviousEmbeds();
    },

    insertButton : function (buttonLabels) {
      var label = 'Embed';
      if (buttonLabels == 'fontawesome' || typeof buttonLabels === 'object' && !!(buttonLabels.fontawesome)) {
        label = '<i class="fa fa-code"></i>';
      }
      return '<button type="button" data-addon="embeds" data-action="add" class="medium-editor-action medium-editor-action-image mediumInsert-action">' + label + '</button>';
    },

    /**
     * Add embed to $placeholder
     * @param {element} $placeholder $placeholder to add embed to
     * @return {void}
     */
    add : function ($placeholder) {
      $.fn.mediumInsert.insert.deselect();


      var formHtml = '<div class="medium-editor-toolbar-form-anchor mediumInsert-embedsWire" style="display: block;"><input type="text" value="" contenteditable="false" placeholder="粘贴视频代码" class="mediumInsert-embedsText"></div>';
      $(formHtml).appendTo($placeholder.prev());
      setTimeout(function () {
        $placeholder.prev().find('input').focus();
      }, 50);

      $.fn.mediumInsert.insert.deselect();

      this.currentPlaceholder = $placeholder;
      $(".mediumInsert-embedsText").focus();
    },

    /**
    * Make existing embeds interactive
    *
    * @return {void}
    */

    preparePreviousEmbeds: function () {
      var $insertBlockTemplate = $($.fn.mediumInsert.insert.insertBlock);

      $insertBlockTemplate
        .removeClass('empty')
        .find('.mediumInsert-placeholder')
          .attr('draggable', true)
          .append($('<div class="mediumInsert-embeds" />'))

      this.$el.find('iframe, embed, object, video, audio, .video, .twitter-tweet, .instagram').each(function() {
        var $this = $(this),
            $insertBlock = $insertBlockTemplate.clone();

        $this.after($insertBlock);
        $this.appendTo($insertBlock.find('.mediumInsert-embeds'));
      });
    },

    /**
     * Change the mediumInsert state to filled.
     *
     * @return {void}
     */
    fill : function () {
      this.currentPlaceholder.closest('.mediumInsert').removeClass('empty');
    },

    setEmbedButtonEvents : function () {
      var that = this;
      $(document).on('keypress', 'input.mediumInsert-embedsText', function (e) {
        if ((e.which && e.which == 13) || (e.keyCode && e.keyCode == 13)) {
          that.fill();
          that.setEnterActionEvents();
          that.removeToolbar();
        }
      });

      this.$el.on('blur', '.mediumInsert-embedsText', function () {
        that.removeToolbar();
      });

    },
    setEnterActionEvents : function () {
      var that = this;
      if ($.fn.mediumInsert.settings.enabled === false) {
        return false;
      }

      var url = $("input.mediumInsert-embedsText").val();
      if (!url) {
        return false;
      }
      var embed_tag = that.convertUrlToEmbedTag(url);
      if (!embed_tag) {
        alert('Incorrect URL format specified');
        return false;
      } else {
        embed_tag = $('<div class="mediumInsert-embeds"></div>').append(embed_tag);
        that.currentPlaceholder.append(embed_tag);
        $.fn.mediumInsert.insert.$el.keyup();
        $.fn.mediumInsert.insert.$el.trigger('input');
      }
    },

    removeToolbar : function () {
      $(".mediumInsert-embedsWire").remove();
    },

    convertUrlToEmbedTag : function (url) {
      var embed_tag = url.replace(/\n?/g, '').replace(/^((http(s)?:\/\/)?(www\.)?(youtube\.com|youtu\.be)\/(watch\?v=|v\/)?)([a-zA-Z0-9-_]+)(.*)?$/, '<div class="video"><iframe width="420" height="315" src="//www.youtube.com/v/$7&amp;fs=1" frameborder="0" allowfullscreen></iframe></div>')
        .replace(/http:\/\/vimeo\.com\/(\d+)$/, '<iframe src="//player.vimeo.com/video/$1" width="500" height="281" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>')
        .replace(/^http:\/\/v\.youku.com\/v_show\/id_(.+)(\.html){1}(.*)/, '<iframe height=498 width=510 src="http://player.youku.com/embed/$1" frameborder=0 allowfullscreen></iframe>')
        .replace(/^http:\/\/www\.tudou\.com\/listplay\/([a-zA-Z0-9]+)\/([a-zA-Z0-9]+)\.html$/, '<iframe src="http://www.tudou.com/programs/view/html5embed.action?type=1&code=$2&lcode=$1&resourceId=0_06_05_99" allowtransparency="true" scrolling="no" border="0" frameborder="0" style="width:480px;height:400px;"></iframe>')
        .replace(/^http:\/\/www\.tudou\.com\/programs\/view\/(.+)$/, '<iframe src="http://www.tudou.com/programs/view/html5embed.action?type=0&code=$1" allowtransparency="true" scrolling="no" border="0" frameborder="0" style="width:480px;height:400px;"></iframe>')
        .replace(/^http:\/\/www\.56\.com\/(.+)\/v_(.+)\.html$/, '<iframe width="480" height="405" src="http://www.56.com/iframe/$2" frameborder="0" allowfullscreen=""></iframe>')
        .replace(/^http:\/\/v\.qq\.com\/page\/(.+)\/(.+)\/(.+)\/([a-zA-Z0-9]+)\.html$/, '<iframe width="480" height="405" frameborder=0 src="http://v.qq.com/iframe/player.html?vid=$4&tiny=0&auto=0" allowfullscreen></iframe>')
        .replace(/https:\/\/twitter\.com\/(\w+)\/status\/(\d+)\/?$/, '<blockquote class="twitter-tweet" lang="en"><a href="https://twitter.com/$1/statuses/$2"></a></blockquote><script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>')
        .replace(/https:\/\/www\.facebook\.com\/(\w+)\/posts\/(\d+)$/, '<div id="fb-root"></div><script>(function(d, s, id) { var js, fjs = d.getElementsByTagName(s)[0]; if (d.getElementById(id)) return; js = d.createElement(s); js.id = id; js.src = "//connect.facebook.net/en_US/all.js#xfbml=1"; fjs.parentNode.insertBefore(js, fjs); }(document, "script", "facebook-jssdk"));</script><div class="fb-post" data-href="https://www.facebook.com/$1/posts/$2"></div>')
        .replace(/http:\/\/instagram\.com\/p\/(.+)\/?$/, '<span class="instagram"><iframe src="//instagram.com/p/$1/embed/" width="612" height="710" frameborder="0" scrolling="no" allowtransparency="true"></iframe></span>');
      return /<("[^"]*"|'[^']*'|[^'">])*>/.test(embed_tag) ? embed_tag : false;
    }

  });

}(jQuery));
