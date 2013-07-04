# -*- coding: utf-8 -*-
module PhotosHelper
  def attachment_tag(data = {})
    file_field_tag "file", data: data.merge(upyun_data)
  end
end
