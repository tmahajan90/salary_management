require "rails_helper"

RSpec.describe Salary, type: :model do
  describe "validations" do
    subject { build(:salary) }

    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_presence_of(:currency) }
    it { is_expected.to validate_presence_of(:effective_from) }
    it { is_expected.to validate_numericality_of(:amount).is_greater_than(0) }
    it { is_expected.to validate_inclusion_of(:currency).in_array(Salary::CURRENCIES) }

    it "rejects effective_to before effective_from" do
      salary = build(:salary, effective_from: Date.today, effective_to: 1.day.ago.to_date)
      expect(salary).not_to be_valid
      expect(salary.errors[:effective_to]).to be_present
    end

    it "allows effective_to after effective_from" do
      salary = build(:salary, effective_from: 1.year.ago.to_date, effective_to: Date.today)
      expect(salary).to be_valid
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:employee) }
  end

  describe "scopes" do
    let(:employee) { create(:employee) }
    let!(:current_salary) { create(:salary, employee: employee, effective_to: nil) }
    let!(:old_salary) do
      create(:salary, employee: employee,
             effective_from: 3.years.ago.to_date,
             effective_to: 2.years.ago.to_date)
    end

    it ".current returns only salaries with no end date" do
      expect(Salary.current).to include(current_salary)
      expect(Salary.current).not_to include(old_salary)
    end

    it ".historical returns only salaries with an end date" do
      expect(Salary.historical).to include(old_salary)
      expect(Salary.historical).not_to include(current_salary)
    end
  end

  describe "auto-closing previous salary" do
    let(:employee) { create(:employee) }

    it "closes the previous current salary when a new one is created" do
      previous = create(:salary, employee: employee,
                        effective_from: 2.years.ago.to_date,
                        effective_to: nil)

      new_effective = 1.month.ago.to_date
      create(:salary, employee: employee, effective_from: new_effective, effective_to: nil)

      expect(previous.reload.effective_to).to eq(new_effective - 1.day)
    end

    it "does not close a salary that starts after the new one" do
      future_salary = create(:salary, employee: employee,
                             effective_from: 1.month.from_now.to_date,
                             effective_to: nil)

      create(:salary, employee: employee,
             effective_from: Date.today,
             effective_to: nil)

      expect(future_salary.reload.effective_to).to be_nil
    end
  end
end
