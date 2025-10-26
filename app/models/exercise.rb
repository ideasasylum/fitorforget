class Exercise < ApplicationRecord
  # Associations
  belongs_to :program

  # Validations
  validates :name, presence: true
  validates :repeat_count, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :video_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }, allow_blank: true
end
