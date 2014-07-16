class AvatarUploader < ImageUploader

  # Provide a default URL as a default if there hasn't been a file uploaded
  def default_url
    i = 1.upto(22).to_a.shuffle.first
    "#{upyun_bucket_host}/logos/" +
        ["#{i}.png", version_name].compact.join('!')
  end
end
