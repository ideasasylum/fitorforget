class Program < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :exercises, -> { order(position: :asc) }, dependent: :destroy
  has_many :workouts, dependent: :nullify  # Workouts persist as snapshots even if program is deleted

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
