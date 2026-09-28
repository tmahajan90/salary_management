class Employee < ApplicationRecord
  has_many :salaries, dependent: :destroy

  STATUSES = %w[active inactive].freeze

  validates :employee_code, presence: true, uniqueness: { case_sensitive: false }
  validates :first_name, :last_name, :department, :job_title, :country, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :status, inclusion: { in: STATUSES }

  scope :active, -> { where(status: "active") }
  scope :inactive, -> { where(status: "inactive") }
  scope :by_department, ->(dept) { where(department: dept) }
  scope :by_country, ->(country) { where(country: country) }
  scope :search, ->(query) {
    return all if query.blank?
    term = "%#{query.downcase}%"
    where(
      "LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ? OR LOWER(email) LIKE ? OR LOWER(employee_code) LIKE ?",
      term, term, term, term
    )
  }

  def full_name
    "#{first_name} #{last_name}"
  end

  def current_salary
    salaries.where(effective_to: nil).order(effective_from: :desc).first
  end
end
