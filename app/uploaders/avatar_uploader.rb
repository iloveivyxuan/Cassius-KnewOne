class AvatarUploader < ImageUploader
  AVATARS = %w(1 3) + (12..20).to_a.map(&:to_s)

  # Provide a default URL as a default if there hasn't been a file uploaded
  def default_url
    "#{upyun_bucket_host}/avatars/" +
        ["#{AVATARS.sample}.png", version_name].compact.join('!')
  end
end
