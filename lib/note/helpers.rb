module Helpers
  private

  def markdown_file_name(note_name:)
    note_name.strip.downcase.
      gsub(/[^a-z0-9]+/, "_").
      gsub(/\A\_+/, "").
      gsub(/\_+\z/, "").
      concat(".md")
  end
end
