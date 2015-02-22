class MailerImageUploader < CarrierWave::Uploader::Base
  storage :file

  unless Rails.env.development?
    def store_dir
      'system'
    end
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

  # Provide a default URL as a default if there hasn't been a file uploaded
  def default_url
    ActionController::Base.helpers.asset_path('mails/bigimage.jpg', type: :image).to_s
  end
end
