# typed: true
# frozen_string_literal: true

# An enum representing card suits
class Suit < T::Enum
  enums do
    # The spades suit
    # @see https://en.wikipedia.org/wiki/Spades_(suit)
    Spades = new
    # The hearts suit
    Hearts = new
    Clubs = new('Clubs')
    diamonds_serialized_value = 'Diamonds'
    Diamonds = new(diamonds_serialized_value)
  end
end
