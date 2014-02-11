var Making = (function(module) {
  module.OlarkSetUser = function(name, email, id) {
    if (typeof name != 'undefined') {
      olark('api.visitor.updateFullName', {fullName: name});
      olark('api.chat.updateVisitorNickname', {snippet: name });
    }
    if (typeof email != 'undefined')
      olark('api.visitor.updateEmailAddress', {emailAddress: email});
    if (typeof id != 'undefined')
      olark('api.visitor.updateCustomFields', {customerId: id});
  };

  return module;
})(window.Making || {});

(function() {
  var feedback = document.getElementById('feedback');

  feedback.addEventListener('click', function(event) {
    event.preventDefault();
    olark('api.box.expand');
  }, false);

  window.addEventListener('touchend', function() {
    var display = 'none';

    if (document.body.scrollTop > 400) {
      display = 'block';
    } else {
      display = 'none';
    }

    feedback.style.display = display;
  }, false);
})();