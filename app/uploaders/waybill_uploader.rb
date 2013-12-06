# -*- coding: utf-8 -*-
class WaybillUploader < CarrierWave::Uploader::Base
  def store_dir
    "#{model.class.to_s.underscore.pluralize}"
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    if super.present?
      @name ||= Digest::MD5.hexdigest(File.dirname(current_path))
      "#{@name}#{File.extname(original_filename).downcase}"
    end
  end
end
