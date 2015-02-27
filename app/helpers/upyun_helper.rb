module UpyunHelper
  def upyun_directory
    {
      default: "photos",
      review: "review_photos"
    }
  end

  def upyun_policy(type)
    raw = {
      "bucket" => Settings.upyun.photo_bucket,
      "expiration" => 3.hours.since.to_i,
      "save-key" => "/#{upyun_directory[type]}/{filemd5}{.suffix}",
      "allow-file-type" => "jpg,jpeg,gif,png",
      "content-length-range" => "0, #{4.megabyte}",
      "x-gmkerl-rotate" => "auto"
    }
    Base64.strict_encode64(raw.to_json)
  end

  def upyun_signature(type)
    Digest::MD5.hexdigest "#{upyun_policy(type)}&#{Settings.upyun.form_secret}"
  end

  def upyun_data(type = :review)
    domain = "http://" + Settings.upyun.photo_bucket_domain
    {
      policy: upyun_policy(type),
      signature: upyun_signature(type),
      url: "http://v0.api.upyun.com/" + Settings.upyun.photo_bucket,
      domain: domain
    }
  end
end
