class StoryPresenter < PostPresenter
  presents :story

  def url
    thing_story_url(story.thing, story)
  end

  def edit_url
    edit_thing_story_url(story.thing, story)
  end

  def occured_at
    time_tag story.occured_at, story.occured_at
  end
end
