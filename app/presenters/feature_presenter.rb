class FeaturePresenter < PostPresenter
  presents :feature

  def path
    thing_feature_path(feature.thing, feature)
  end

  def edit_path
    edit_thing_feature_path(feature.thing, feature)
  end

  def fancy_path
    fancy_thing_feature_path(feature.thing, feature)
  end

  def dom_id
    "feature_#{feature.id}"
  end
end
