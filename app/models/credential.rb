# == Schema Information
#
# Table name: credentials
#
#  id          :integer          not null, primary key
#  nickname    :string
#  public_key  :text             not null
#  sign_count  :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  external_id :string           not null
#  user_id     :integer          not null
#
class Credential < ApplicationRecord
  # Associations
  belongs_to :user

  # Validations
  validates :external_id, presence: true
  validates :external_id, uniqueness: true
  validates :public_key, presence: true
  validates :user_id, presence: true
end
