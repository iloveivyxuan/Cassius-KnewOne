class FeaturePresenter < PostPresenter
  presents :feature

  def path
    thing_feature_path(feature.thing, feature)
  end

  def edit_path
    edit_thing_feature_path(feature.thing, feature)
  end
end
