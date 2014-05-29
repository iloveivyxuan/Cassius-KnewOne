# -*- coding: utf-8 -*-
class ImageUploader < CarrierWave::Uploader::Base
  include Sprockets::Rails::Helper

  def store_dir
    "#{model.class.to_s.underscore.pluralize}"
  end

  # Override url method to implement with "Image Space"
  def url(version_name = nil)
    @url ||= super({})
    [@url, version_name].compact.join('!') if @url
  end

  # Add a white list of extensions which are allowed to be uploaded.
  def extension_white_list
    %w(jpg jpeg gif png JPG JPEG GIF PNG)
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
