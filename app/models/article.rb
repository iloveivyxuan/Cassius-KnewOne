class Article < Post

  before_save :correct_spaces

  def correct_spaces
    self.content.auto_correct!
  end

end
