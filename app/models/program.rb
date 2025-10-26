class Program < ApplicationRecord
  # Associations
  belongs_to :user

  # Validations
  validates :title, presence: true
  validates :title, length: { maximum: 200 }

  # Callbacks
  before_create :generate_uuid

  # Use UUID for URLs instead of ID
  def to_param
    uuid
  end

  private

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end
end
