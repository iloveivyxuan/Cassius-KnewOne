do (exports = Making, $ = jQuery) ->
  exports.validatePhone = (element) ->
    $(element).on 'change', (event) ->
      if (isNaN(this.value) or this.value.length != 11)
        alert('请填写有效的手机号码。')
        this.value=''

  return
