# typed: true
# frozen_string_literal: true

class Suit < T::Enum
  enums do
    Spades = new
    Hearts = new
    Clubs = new
    Diamonds = new
  end
end