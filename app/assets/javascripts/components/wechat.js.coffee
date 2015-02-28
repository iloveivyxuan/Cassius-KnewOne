Making.logIntoWechat = ->
  state = window.location.toString()
  url = "/users/auth/wechat?scope=snsapi_base&state=#{encodeURIComponent(state)}"
  window.location = url
