/*!
 * medium-editor-insert-plugin v0.1.1 - jQuery insert plugin for MediumEditor
 *
 * Video Addon
 *
 * https://github.com/orthes/medium-editor-images-plugin
 *
 * Copyright (c) 2013 Pavel Linkesch (http://linkesch.sk)
 * Released under the MIT license
 */

(function ($) {

  $.fn.mediumInsert.videos = {

    /**
    * Videos initial function
    * @return {void}
    */

    init: function () {
      this.$el = $.fn.mediumInsert.insert.$el;
      this.options = $.extend(this.default,
        $.fn.mediumInsert.settings);
    },

    /**
    * Videos default options
    */

    default: {
      formatData: function (file) {
        var formData = new FormData();
        formData.append('file', file);
        return formData;
      }
    },

    /**
    * Add image to placeholder
    * @param {element} $placeholder Placeholder to add video to
    * @return {void}
    */

    add: function ($placeholder, $trigger) {
      var that = this,
          promptDeferred, $video;

      promptDeferred = new $.Deferred();
      promptDeferred.done(function() {
        $video = $($(that.options.videosPlugin.input).val());
        $placeholder.append($video);
      });

      $trigger.data('deferredMediumInsert', promptDeferred);

      $.fn.mediumInsert.insert.deselect();
    }
  };
}(jQuery));
