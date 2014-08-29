window.Making = (function(module) {
  module.SetupOlark = function(element) {
    var $element    = $(element),
        klass_hint  = $element.data('hint'),
        klass_spin  = 'fa-spinner fa-spin',
        $hint       = $element.find('.' + klass_hint),
        initialized = false;

    $element.on('click', function(event) {
      event.preventDefault();

      if (!initialized) {
        if ($hint.length > 0) {
          $hint.removeClass(klass_hint).addClass(klass_spin);
        }

        $.getScript($element.data('url'), function() {
          var name  = $element.data('name'),
              email = $element.data('email'),
              id    = $element.data('id');

          if (name) {
            olark('api.visitor.updateFullName', {fullName: name});
            olark('api.chat.updateVisitorNickname', {snippet: name });
          }
          if (email) olark('api.visitor.updateEmailAddress', {emailAddress: email});
          if (id) olark('api.visitor.updateCustomFields', {customerId: id});

          olark('api.box.expand');

          if ($hint.length > 0) {
            olark('api.box.onExpand', function() {
              $hint.removeClass(klass_spin).addClass(klass_hint);
            });
          }

          initialized = true;
        });
      } else {
        olark('api.box.expand');
      }
    });
  };

  return module;
})(window.Making || {});

$(function() {
  window.Making.SetupOlark('#feedback');
})();
