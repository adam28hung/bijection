class Link < ActiveRecord::Base
  acts_as_token token_length: 6
end
