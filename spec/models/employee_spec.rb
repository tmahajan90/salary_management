require "rails_helper"

RSpec.describe Employee, type: :model do
  describe "validations" do
    subject { build(:employee) }

    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:department) }
    it { is_expected.to validate_presence_of(:job_title) }
    it { is_expected.to validate_presence_of(:country) }
    it { is_expected.to validate_uniqueness_of(:employee_code).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_inclusion_of(:status).in_array(Employee::STATUSES) }

    it "rejects invalid email format" do
      employee = build(:employee, email: "not-an-email")
      expect(employee).not_to be_valid
      expect(employee.errors[:email]).to be_present
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:salaries).dependent(:destroy) }
  end

  describe "scopes" do
    let!(:active_emp) { create(:employee, status: "active", department: "Engineering", country: "India") }
    let!(:inactive_emp) { create(:employee, status: "inactive", department: "HR", country: "US") }

    it ".active returns only active employees" do
      expect(Employee.active).to include(active_emp)
      expect(Employee.active).not_to include(inactive_emp)
    end

    it ".by_department filters by department" do
      expect(Employee.by_department("Engineering")).to include(active_emp)
      expect(Employee.by_department("Engineering")).not_to include(inactive_emp)
    end

    it ".by_country filters by country" do
      expect(Employee.by_country("India")).to include(active_emp)
      expect(Employee.by_country("India")).not_to include(inactive_emp)
    end

    it ".search matches on first_name" do
      results = Employee.search(active_emp.first_name)
      expect(results).to include(active_emp)
    end

    it ".search matches on email" do
      results = Employee.search(active_emp.email.split("@").first)
      expect(results).to include(active_emp)
    end

    it ".search returns all when query is blank" do
      expect(Employee.search("").count).to eq(Employee.count)
    end
  end

  describe "#full_name" do
    it "returns first and last name joined" do
      employee = build(:employee, first_name: "Jane", last_name: "Doe")
      expect(employee.full_name).to eq("Jane Doe")
    end
  end

  describe "#current_salary" do
    let(:employee) { create(:employee) }

    it "returns the salary with no effective_to date" do
      old = create(:salary, employee: employee, effective_from: 2.years.ago.to_date, effective_to: 1.year.ago.to_date)
      current = create(:salary, employee: employee, effective_from: 1.year.ago.to_date + 1.day, effective_to: nil)

      expect(employee.current_salary).to eq(current)
    end

    it "returns nil when no salary exists" do
      expect(employee.current_salary).to be_nil
    end
  end
end
