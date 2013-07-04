# -*- coding: utf-8 -*-
class Update < Post
  belongs_to :thing
  default_scope desc(:created_at)
end
