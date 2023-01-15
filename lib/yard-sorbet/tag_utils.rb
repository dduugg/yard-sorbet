# typed: true
# frozen_string_literal: true

module YARDSorbet
  # Helper methods for working with `YARD` tags
  module TagUtils
    # The `void` return type, as a constant to reduce array allocations
    VOID_RETURN_TYPE = ['void'].freeze

    # @return the tag with the matching `tag_name` and `name`, or `nil`
    def self.find_tag(docstring, tag_name, name)
      docstring.tags.find { _1.tag_name == tag_name && _1.name == name }
    end

    # Create or update a `YARD` tag with type information
    def self.upsert_tag(docstring, tag_name, types = nil, name = nil, text = '')
      tag = find_tag(docstring, tag_name, name)
      if tag
        return unless types

        # Updating a tag in place doesn't seem to work, so we'll delete it, add the types, and re-add it
        docstring.delete_tag_if { _1 == tag }
        # overwrite any existing type annotation (sigs should win)
        tag.types = types
        tag.text = text unless text.empty?
      else
        tag = YARD::Tags::Tag.new(tag_name, text, types, name)
      end
      docstring.add_tag(tag)
    end
  end
end
