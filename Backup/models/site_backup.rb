# encoding: utf-8

##
# Backup Generated: my_backup
# Once configured, you can run the backup with the following command:
#
# $ backup perform -t my_backup [-c <path_to_configuration_file>]
#
Backup::Model.new(:site_backup, "backup site's database") do
  ##
  # Split [Splitter]
  #
  # Split the backup file in to chunks of 250 megabytes
  # if the backup file size exceeds 250 megabytes
  #
  split_into_chunks_of 250

  ##
  # MongoDB [Database]
  #
  database MongoDB do |db|
    db.name               = "my_database_name"
    db.username           = "my_username"
    db.password           = "my_password"
    db.host               = "localhost"
    db.port               = 5432
    db.ipv6               = false
    db.only_collections   = ["only", "these", "collections"]
    db.additional_options = []
    db.lock               = false
    db.oplog              = false
  end

  ##
  # Gzip [Compressor]
  #
  compress_with Gzip

  ##
  # Mail [Notifier]
  #
  # The default delivery method for Mail Notifiers is 'SMTP'.
  # See the Wiki for other delivery options.
  # https://github.com/meskyanichi/backup/wiki/Notifiers
  #
  notify_by Mail do |mail|
    mail.on_success           = true
    mail.on_warning           = true
    mail.on_failure           = true

    mail.from                 = "sender@email.com"
    mail.to                   = "receiver@email.com"
    mail.address              = "smtp.gmail.com"
    mail.port                 = 587
    mail.domain               = "your.host.name"
    mail.user_name            = "sender@email.com"
    mail.password             = "my_password"
    mail.authentication       = "plain"
    mail.encryption           = :starttls
  end

end
