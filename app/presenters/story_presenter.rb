class StoryPresenter < PostPresenter
  presents :story

  def path
    thing_story_path(story.thing, story)
  end

  def edit_path
    edit_thing_story_path(story.thing, story)
  end

  def occured_at
    time_tag story.occured_at, story.occured_at
  end
end
