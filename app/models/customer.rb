# == Schema Information
#
# Table name: customers
#
#  id              :integer          not null, primary key
#  name            :string           not null
#  organization_id :integer          not null
#  created_at      :datetime
#  updated_at      :datetime
#  deleted_at      :datetime
#

class Customer < ActiveRecord::Base
  acts_as_paranoid

  scope :ordered, -> { order('created_at DESC') }

  belongs_to :organization, inverse_of: :customers
  has_many :transactions, inverse_of: :customer
  has_many :invoices, inverse_of: :customer
  has_many :invoice_items

  validates :name, presence: true
  validates :organization, presence: true
  validates :name, uniqueness: { scope: [:organization_id, :deleted_at] }

  # gem 'paranoia' doesn't run validation callbacks on restore
  before_restore :run_validations

  def to_s
    name.truncate(30)
  end

  private

  def run_validations
    self.deleted_at = nil
    self.validate!
  end
end
