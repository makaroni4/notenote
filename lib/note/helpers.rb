module Helpers
  private

  def markdown_file_name(note_name:)
    note_name.strip.downcase.
      gsub(/[^a-z0-9]+/, "_").
      gsub(/\A\_+/, "").
      gsub(/\_+\z/, "").
      concat(".md")
  end

  def upcate_first(str)
    return if str.nil?
    return "" if str.empty?

    str.tap { |s| s[0] = s[0].upcase }
  end
end
