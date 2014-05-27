!function ($) {

    /* MODAL POPOVER PUBLIC CLASS DEFINITION
     * =============================== */

    var ModalPopover = function (element, options) {
        var that = this;
        this.options = options;
        this.$element = $(element);
        this.options.remote && this.$element.find('.popover-content').load(this.options.remote);
        this.$parent = options.$parent; // todo make sure parent is specified
    }


    /* NOTE: MODAL POPOVER EXTENDS BOOTSTRAP-MODAL.js
     ========================================== */


    ModalPopover.prototype = $.extend({}, $.fn.modal.Constructor.prototype, {

        constructor:ModalPopover,

        getPosition:function () {
            var parentOffset = this.$parent.offset();
            var elementOffset = this.$element.offset();
            var finalOffset = {'top':(parentOffset.top-elementOffset.top),'left':this.$parent[0].offsetLeft};
            return $.extend({}, finalOffset, {
                width:this.$parent[0].offsetWidth, height:this.$parent[0].offsetHeight
            });
        },

        show:function () {
            var $dialog = this.$element;
            $dialog.css({ top:0, left:0, display:'block', 'z-index':1050 });

            var placement = typeof this.options.placement == 'function' ?
                this.options.placement.call(this, $tip[0], this.$element[0]) :
                this.options.placement;

            var pos = this.getPosition();

            var elVerticalCenter = pos.top + pos.height / 2;
            var elHorizontalCenter = pos.left + pos.width / 2;


            var actualWidth = $dialog[0].offsetWidth;
            var actualHeight = $dialog[0].offsetHeight;

            var tp;
            switch (placement) {
                case 'bottom':
                    tp = {top:pos.top + pos.height, left:pos.left + pos.width / 2 - actualWidth / 2}
                    break;
                case 'top':
                    tp = {top:pos.top - actualHeight, left:pos.left + pos.width / 2 - actualWidth / 2}
                    break;
                case 'left':
                    tp = {top:elVerticalCenter - actualHeight / 2, left:pos.left - actualWidth}
                    break;
                case 'right':
                    tp = {top:elVerticalCenter - actualHeight / 2, left:pos.left + pos.width}
                    break;
            }


            if(placement === 'left' || placement === 'right'){

              //TODO: create option to detect document margins
              //Fix overflow top
              if(tp.top < 20)
              {
                tp.top = 20;

                if(this.$element.offset().top)
                {
                  tp.top = 0;
                }
              }

              //Fix arrow
              var arrow = $dialog.find('.arrow');
              arrow.css('top', (elVerticalCenter-tp.top));

            }

            $dialog
                .css(tp)
                .addClass(placement)
                .addClass('in');


            $.fn.modal.Constructor.prototype.show.call(this, arguments); // super
        },

        // removed backdrop compatibility because we dont need it for popovers :)
        backdrop:function (callback) {
          callback()
        }

    });


    /* MODAL POPOVER PLUGIN DEFINITION
     * ======================= */

    $.fn.modalPopover = function (option) {
      return this.each(function () {
        var $this = $(this);
        var data = $this.data('modal-popover');
        var options = $.extend({}, $.fn.modalPopover.defaults, $this.data(), typeof option == 'object' && option);
        // todo need to replace 'parent' with 'target'
        options['$parent'] = (data && data.$parent) || options.$parent || $(options.target);

        if (!data) $this.data('modal-popover', (data = new ModalPopover(this, options)))

        if (typeof option == 'string') data[option]()

        var docClickEvent = function(event){
          if($(event.target).parents().index($this) === -1 && $(event.target).parents().index(options.$parent) === -1){
            $this.modalPopover('hide');
            $(document).unbind('click', docClickEvent);
          }
        };

        $('[data-dismiss="modal-popup"]').on('click',function(){
          var e = $.Event('hide.bs.modal');
          $this.trigger(e);
          $this.hide();
          $(document).unbind('click', docClickEvent);
        });

        $this.one('shown.bs.modal',function(){
          setTimeout(function(){
            $(document).on('click', docClickEvent);
          },0);
        });

      })
    }

    $.fn.modalPopover.Constructor = ModalPopover;

    $.fn.modalPopover.defaults = $.extend({}, $.fn.modal.defaults, {
        placement:'right',
        keyboard: true
    });


    $(function () {
      $('body').on('click.modal-popover.data-api', '[data-toggle="modal-popover"]', function (e) {
          var $this = $(this);
          var href = $this.attr('href');
          var $dialog = $($this.attr('data-target') || (href && href.replace(/.*(?=#[^\s]+$)/, ''))); //strip for ie7
          var option = $dialog.data('modal-popover') ? 'toggle' : $.extend({ remote:!/#/.test(href) && href }, $dialog.data(), $this.data());
          option['$parent'] = $this;

          e.preventDefault();

          $dialog
          .modalPopover(option)
          .modalPopover('show');
      })
    })

}(window.jQuery);
//