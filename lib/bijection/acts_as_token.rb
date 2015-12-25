module Bijection
  module ActsAsToken
    extend ActiveSupport::Concern

    included do
    end
    # HOW TO protect alphabet being changed
    module ClassMethods

      def acts_as_token(options = {})
        cattr_accessor :token_string_field, :alphabet, :shiftnumber
        self.token_string_field = (options[:token_string_field] || :slug).to_s

        sequence = options[:char_base] ||
          "XUVDB53RFj8SrgbyTfMkCQ2d7wHYizmu0Alsn6OoGvcIP9xNWe4tKh1qpEJaLZ"
        # (('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a).shuffle.join.split(//) # 62
        self.alphabet = sequence.split(//)
        token_length = options[:token_length] || 5
        self.shiftnumber = 62**(token_length - 1)
      end

      def generate_shortener_token(record)
        if record.present?
          self.encode(record.id)
        end
      end
      # http://where.to.go/articles/R3338
      # Article.resolve_shortener_token('R3338')
      def resolve_shortener_token(token)
        if %r{^[a-zA-Z0-9]{5,7}$} === token
          begin
            self.find self.decode(token)
          rescue
            nil
          end
        end
      end

      def is_token_valid?(token)
        %r{^[a-zA-Z0-9]{5,7}$} === token
      end

      def encode(seed)
        seed += self.shiftnumber
        return self.alphabet[0] if seed == 0
        token = ''
        base = self.alphabet.length

        while seed > 0
          token << self.alphabet[seed.modulo(base)]
          seed /= base
        end
        token.reverse
      end

      def decode(token)
        seed = 0
        base = self.alphabet.length
        token.each_char { |c| seed = seed * base + self.alphabet.index(c) }
        seed -= self.shiftnumber
      end

      def alphabets
        self.alphabet.join
      end

      def shift_number
        self.shiftnumber
      end

    end

    # instance methods
    #
    def generate_shortener_token(seed=id)
      if seed.is_a? Integer
        token = self.class.encode(seed)
        write_attribute(self.class.token_string_field, token)
      end
    end

    def resolve_shortener_token(token)
      if %r{^[a-zA-Z0-9]{5,7}$} === token
        self.class.decode(token)
      end
    end

  end
end

ActiveRecord::Base.send :include, Bijection::ActsAsToken
