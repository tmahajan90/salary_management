FactoryBot.define do
  factory :salary do
    association :employee
    amount       { 1_200_000.0 }
    currency     { "INR" }
    effective_from { 1.year.ago.to_date }
    effective_to   { nil }
    notes          { "Annual review" }
  end
end
