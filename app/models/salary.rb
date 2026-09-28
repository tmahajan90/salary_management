class Salary < ApplicationRecord
  belongs_to :employee

  CURRENCIES = %w[USD INR GBP EUR AUD CAD SGD AED JPY BRL MXN].freeze

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true, inclusion: { in: CURRENCIES }
  validates :effective_from, presence: true
  validate :effective_to_after_effective_from

  scope :current, -> { where(effective_to: nil) }
  scope :historical, -> { where.not(effective_to: nil) }
  scope :ordered, -> { order(effective_from: :desc) }

  before_create :close_previous_salary

  private

  def effective_to_after_effective_from
    return unless effective_to && effective_from
    errors.add(:effective_to, "must be after effective from date") if effective_to <= effective_from
  end

  # Automatically closes the previous active salary when a new one is recorded
  def close_previous_salary
    employee.salaries.current.where("effective_from < ?", effective_from).each do |s|
      s.update_columns(effective_to: effective_from - 1.day)
    end
  end
end
