# typed: strict
# frozen_string_literal: true

# Helper methods for working with `YARD` tags
module YARDSorbet::TagUtils
  extend T::Sig

  # Create or update a `YARD` tag with type information
  sig do
    params(
      docstring: YARD::Docstring,
      tag_name: String,
      types: T.nilable(T::Array[String]),
      name: T.nilable(String)
    ).void
  end
  def self.upsert_tag(docstring, tag_name, types = nil, name = nil)
    tag = docstring.tags.find { |t| t.tag_name == tag_name && t.name == name }
    if tag
      return unless types

      # Updating a tag in place doesn't seem to work, so we'll delete it, add the types, and re-add it
      docstring.delete_tag_if { |t| t == tag }
      # overwrite any existing type annotation (sigs should win)
      tag.types = types
    else
      tag = YARD::Tags::Tag.new(tag_name, '', types, name)
    end
    docstring.add_tag(tag)
  end
end
