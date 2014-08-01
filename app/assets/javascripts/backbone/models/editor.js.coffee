Making.Models.Editor = Backbone.Model.extend
  defaults:
    status: ''
    persisten: null

  updateStatus: (status) ->

    switch status
      when 'load'
        @set 'status', '正在加载'
      when 'edit'
        @set 'status', ''
      when 'save'
        @set 'status', '正在保存'
      when 'drop'
        @set 'status', '正在删除'
      when 'submit'
        @set 'status', '正在发布'
