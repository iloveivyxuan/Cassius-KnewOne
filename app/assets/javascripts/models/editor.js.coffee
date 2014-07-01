Making.Models.Editor = Backbone.Model.extend
  defaults:
    status: ''
    persisten: false
    
  updateStatus: (status) ->

    switch status
      when 'load'
        @set 'status', '正在加载'
      when 'edit'
        @set 'status', ''
      when 'save'
        @set 'status', '正在保存草稿'
      when 'drop'
        @set 'status', '正在删除文档'
      when 'submit'
        @set 'status', '正在发布文档'
