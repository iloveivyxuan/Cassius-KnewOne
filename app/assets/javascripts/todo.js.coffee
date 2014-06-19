# TODO
do (exports = Making) ->

  _.extend exports,

    InitUIThings: ($things) ->
      $things.length and $things.each ->
        $thing = $(@)
        $thing.find('h5').tooltip()

    ThingsNew: ->
      $ ->
        view = new Making.Views.ThingsNew
          el: "form.thing_form"

    FeelingsNew: ->
      $ ->
        view = new Making.Views.FeelingNew
          el: '.feeling_form > .editor_compact'

    FormLink: (form, button) ->
      $ ->
        $(button).click ->
          is_sync = $('#check_provider_sync input').prop('checked')
          $("<input name='provider_sync' type='hidden' value=#{is_sync}>").appendTo(form)
          $(form).submit()

    Editor: (textarea, validate = false) ->
      $ ->
        $("#editor")
        .wysiwyg
            dragAndDropImages: false
        .html($(textarea).val())
        .fadeIn()
        .on "drop", (e) ->
            e.stopPropagation()

        $("#editor-toolbar")
        .fadeIn()
        #https://github.com/twitter/bootstrap/issues/5687
        .find('.btn-group > a').tooltip({container: 'body'}).end()
        .find('.dropdown-menu input')
        .click ->
            false
        .change ->
            $(@).parent('.dropdown-menu')
            .siblings('.dropdown-toggle').dropdown('toggle')
        .end()
        .find('input[type="file"]')
        .each ->
            $overlay = $(@)
            $target = $($overlay.data('target'))
            $overlay
            .css('opacity', 0)
            .css('position', 'absolute')
            .attr('title', "插入图像(可以拖拽)")
            .tooltip()
            .offset($target.offset())
            .width($target.outerWidth())
            .height($target.outerHeight())

        $(textarea).closest('form')
          .on 'submit', (e) ->
            $editor = $('#editor')
            if validate and $editor.text().length < 140
              $('<p>')
                .addClass('alert alert-danger')
                .text('内容有点少，建议再详细描述下（至少 140 字）。')
                .insertAfter($editor)
              return false
            else
              $alert = $editor.next('p.alert')
              if $alert.length then $alert.remove()

            $editor.find('a').attr('target', '_blank')
            resque = $editor.html()
            $(textarea).val resque.replace(/<!--.*?-->/g, '')

    Share: ->
      share_content_length = ($el) ->
        count = 0.0
        for w in $el.val().replace(/http:\/\/[a-z]+\.[^ \u4e00-\u9fa5]+/g, 'urlurlhereurlurlhere')
          count += (if /[\x00-\xff]/.test(w) then 0.5 else 1.0)
        Math.ceil(count)

      control_modal = ($el) ->
        available_words = 140 - share_content_length($el.find('textarea'))
        if available_words > 0
          $el.find('input[type="submit"]').removeAttr('disabled')
        else
          $el.find('input[type="submit"]').attr('disabled', 'disabled')
        $el.find('.words-check').text("还可以输入#{available_words}字")

      $modal = $(".share_modal")

      $modal.on('propertychange input', 'textarea', -> control_modal($(@).closest('.share_modal')))
      $modal.on('shown', -> control_modal($(@)))
      $modal.on("submit form", -> $modal.modal("hide"))

    Comments: (el) ->
      $ ->
        post_id = $(el).data('postid')
        collection = new Making.Collections.Comments
        collection.url = "/posts/#{post_id}/comments"
        view = new Making.Views.CommentsIndex
          collection: collection
          el: el

    InfiniteScroll: (container, item) ->
      $('.pagination').hide()
      $(container).infinitescroll
        navSelector: '.pagination'
        nextSelector: '.pagination a[rel="next"]'
        contentSelector: container + ' ul.infinite'
        itemSelector: 'ul.infinite > li'
        pixelsFromNavToBottom: 150
        loading:
          msg: $("<div class='loading-things'><i class='fa fa-spinner fa-spin fa-2x'></i></div>")
        errorCallback: ->
          $(container).find('.loading-things').html('<em class="nomore">没有更多了。</em>')
        , (data) ->
          $('.loading-things').remove()
          $(data).find(".lazy").css("visibility", "visible").lazyload
            threshold: 400

    CalculatePrice: ($el) ->
      price = parseFloat($el.children('.price').attr('data-price'))
      quantity = parseFloat($el.children('.item_quantity').val())
      $el.children('.price').text("￥ #{price * quantity}")

    ImageLazyLoading: () ->
      $("img.lazy")
        .filter ->
          $(@).css('visibility') is 'hidden'
        .css('visibility', 'visible')
        .lazyload
          threshold: 0

    ExtendCarousel: ->
      $('.carousel').each ->
        $carousel      = $(@)
        $inner         = $carousel.find('.carousel-inner')
        $item          = $inner.children('.item')
        default_height = parseInt($item.css('max-height'))
        height         = _.min([default_height, $inner.width() * 0.75]) + 'px'

        if !$html.hasClass('mobile')
          $item.css
            height: height
            lineHeight: height

        if Modernizr.mq('(min-width: ' + Making.Breakpoints.screenSMMin + ')')
          $overview      = $carousel.next('.carousel_overview')
          $overview_body = $overview.children('.slideshow_body')

          if $overview_body.length and $overview_body.is(':visible')
            $prevPage = $overview.find('.left')
            $nextPage = $overview.find('.right')

            $overview_body.sly
              horizontal: 1
              itemNav: 'centered'
              smart: 1
              activateOn: 'click'
              mouseDragging: 1
              touchDragging: 1
              releaseSwing: 1
              speed: 300
              elasticBounds: 1
              dragHandle: 1
              dynamicHandle: 1
              clickBar: 1
              prevPage: $prevPage
              nextPage: $nextPage

            $carousel.on 'slid.bs.carousel', ->
              index = $(@).find('.carousel-inner').children('.item').filter('.active').index()
              $overview.find('.slideshow_inner').children('li').eq(index).addClass('active').siblings().removeClass('active')

  return
