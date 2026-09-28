FactoryBot.define do
  factory :employee do
    sequence(:employee_code) { |n| format("EMP-%05d", n) }
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    sequence(:email) { |n| "employee#{n}@acme-corp.com" }
    department { "Engineering" }
    job_title  { "Software Engineer" }
    country    { "India" }
    hire_date  { 2.years.ago.to_date }
    status     { "active" }

    trait :inactive do
      status { "inactive" }
    end

    trait :with_salary do
      after(:create) do |employee|
        create(:salary, employee: employee)
      end
    end
  end
end
