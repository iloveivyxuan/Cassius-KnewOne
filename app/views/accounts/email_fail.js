$('#setting-email .user_email').addClass('has-error');
$('#setting-email .user_email .controls .help-block').
    text('<%= resource.errors[:email].join('<br>') %>').removeClass('hidden');
