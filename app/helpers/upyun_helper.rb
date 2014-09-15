module UpyunHelper
  def upyun_policy
    raw = {
      "bucket" => Settings.upyun.photo_bucket,
      "expiration" => 3.hours.since.to_i,
      "save-key" => "/review_photos/{filemd5}{.suffix}",
      "allow-file-type" => "jpg,jpeg,gif,png",
      "content-length-range" => "0, #{4.megabyte}",
      "x-gmkerl-rotate" => "auto"
    }
    Base64.strict_encode64(raw.to_json)
  end

  def upyun_signature
    Digest::MD5.hexdigest "#{upyun_policy}&#{Settings.upyun.form_secret}"
  end

  def upyun_data
    domain = "http://" + Settings.upyun.photo_bucket_domain
    {
      policy: upyun_policy,
      signature: upyun_signature,
      url: "http://v0.api.upyun.com/" + Settings.upyun.photo_bucket,
      domain: domain
    }
  end
end
