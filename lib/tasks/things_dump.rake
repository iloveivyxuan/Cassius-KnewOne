desc "Dump all things to target file"
task :things_dump, [:target] => [:environment] do |t, args|
  include Rails.application.routes.url_helpers
  d = "##"

  File.open args[:target], "w+" do |f|
    f.puts [
            "Thing Title",
            "URL",
            "Fancy Users",
            "Own Users",
            "Fancy Groups",
            "Reviews",
            "Comments"].join(d)

    f.puts '-'*80

    Thing.all.each do |t|
      f.puts [
              t.title,
              thing_url(t, host: "http://knewone.com"),
              t.fanciers.count,
              t.owners.count,
              t.fancy_groups.count,
              t.reviews.count,
              t.comments.count].join(d)
    end
  end
end
