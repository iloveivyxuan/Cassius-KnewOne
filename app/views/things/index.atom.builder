atom_feed language: "zh-CN" do |feed|
  feed.title "Knewone"
  feed.updated @things.first.created_at if @things.length > 0

  @things.each do |thing|
    feed.entry thing, url: thing_url(thing) do |entry|
      entry.title thing.title
      entry.subtitle thing.subtitle
      entry.content thing.content
      entry.cover thing.cover.url(:normal)
      entry.author do |author|
        author.name thing.author.name
      end
    end
  end
end
