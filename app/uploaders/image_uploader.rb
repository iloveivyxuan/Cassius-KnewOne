# -*- coding: utf-8 -*-
class ImageUploader < CarrierWave::Uploader::Base
  def store_dir
    "#{model.class.to_s.underscore.pluralize}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded
  def default_url
    i = 1.upto(22).to_a.shuffle.first
    "http://#{upyun_bucket_domain}/logos/" +
        ["#{i}.png", version_name].compact.join('!')
  end

  # Override url method to implement with "Image Space"
  def url(version_name = nil)
    @url ||= super({})
    [@url, version_name].compact.join('!')
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
