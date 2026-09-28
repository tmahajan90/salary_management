require "faker"

puts "Seeding database..."

DEPARTMENTS = [
  "Engineering", "Product", "Design", "Marketing", "Sales",
  "Finance", "HR", "Operations", "Legal", "Customer Success",
  "Data Science", "DevOps", "QA", "Security", "Business Development"
].freeze

COUNTRIES_WITH_CURRENCIES = {
  "India"          => { currency: "INR", salary_range: [600_000, 4_500_000] },
  "United States"  => { currency: "USD", salary_range: [60_000, 250_000] },
  "United Kingdom" => { currency: "GBP", salary_range: [35_000, 180_000] },
  "Germany"        => { currency: "EUR", salary_range: [40_000, 160_000] },
  "Australia"      => { currency: "AUD", salary_range: [65_000, 220_000] },
  "Canada"         => { currency: "CAD", salary_range: [55_000, 200_000] },
  "Singapore"      => { currency: "SGD", salary_range: [50_000, 180_000] },
  "UAE"            => { currency: "AED", salary_range: [80_000, 400_000] },
  "Brazil"         => { currency: "BRL", salary_range: [60_000, 350_000] },
  "Mexico"         => { currency: "MXN", salary_range: [120_000, 700_000] }
}.freeze

JOB_TITLES_BY_DEPARTMENT = {
  "Engineering"         => ["Software Engineer", "Senior Software Engineer", "Staff Engineer", "Principal Engineer", "Engineering Manager", "Tech Lead"],
  "Product"             => ["Product Manager", "Senior PM", "Director of Product", "Associate PM", "Group PM"],
  "Design"              => ["UX Designer", "UI Designer", "Product Designer", "Design Lead", "Head of Design"],
  "Marketing"           => ["Marketing Manager", "Content Strategist", "Growth Manager", "Brand Manager", "Digital Marketing Specialist"],
  "Sales"               => ["Sales Executive", "Account Executive", "Sales Manager", "VP of Sales", "Sales Development Rep"],
  "Finance"             => ["Financial Analyst", "Senior Accountant", "Finance Manager", "Controller", "CFO"],
  "HR"                  => ["HR Manager", "Recruiter", "HR Business Partner", "Talent Acquisition Lead", "People Operations"],
  "Operations"          => ["Operations Manager", "Operations Analyst", "Chief of Staff", "Process Manager", "Business Analyst"],
  "Legal"               => ["Legal Counsel", "Senior Counsel", "Compliance Manager", "Contract Manager", "VP Legal"],
  "Customer Success"    => ["Customer Success Manager", "Account Manager", "Support Engineer", "CS Lead", "Head of CS"],
  "Data Science"        => ["Data Scientist", "ML Engineer", "Data Analyst", "Analytics Engineer", "Head of Data"],
  "DevOps"              => ["DevOps Engineer", "SRE", "Platform Engineer", "Cloud Architect", "Infrastructure Lead"],
  "QA"                  => ["QA Engineer", "Senior QA", "QA Lead", "SDET", "QA Manager"],
  "Security"            => ["Security Engineer", "Penetration Tester", "Security Analyst", "CISO", "Cloud Security Engineer"],
  "Business Development"=> ["BD Manager", "Partnerships Lead", "BD Executive", "Head of BD", "Strategic Alliances Manager"]
}.freeze

TOTAL_EMPLOYEES = 10_000
BATCH_SIZE = 500

# Distribution: ~50% India, ~20% US, rest spread across others
COUNTRY_WEIGHTS = {
  "India"          => 5000,
  "United States"  => 2000,
  "United Kingdom" => 700,
  "Germany"        => 500,
  "Australia"      => 400,
  "Canada"         => 400,
  "Singapore"      => 300,
  "UAE"            => 200,
  "Brazil"         => 250,
  "Mexico"         => 250
}.freeze

weighted_countries = COUNTRY_WEIGHTS.flat_map { |country, weight| Array.new(weight, country) }

puts "Clearing existing data..."
Salary.delete_all
Employee.delete_all

puts "Generating #{TOTAL_EMPLOYEES} employees in batches of #{BATCH_SIZE}..."

employee_counter = 0
(TOTAL_EMPLOYEES / BATCH_SIZE).times do |batch|
  employees_data = []
  salaries_data = []
  now = Time.current

  BATCH_SIZE.times do
    employee_counter += 1
    country = weighted_countries.sample
    config = COUNTRIES_WITH_CURRENCIES[country]
    department = DEPARTMENTS.sample
    hire_date = Faker::Date.between(from: 5.years.ago, to: Date.today)
    status = employee_counter <= 9500 ? "active" : "inactive"

    employees_data << {
      employee_code: format("EMP-%05d", employee_counter),
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      email: "#{Faker::Internet.unique.username(specifier: 6..12)}_#{employee_counter}@acme-corp.com",
      department: department,
      job_title: JOB_TITLES_BY_DEPARTMENT[department].sample,
      country: country,
      hire_date: hire_date,
      status: status,
      created_at: now,
      updated_at: now
    }
  end

  inserted = Employee.insert_all(employees_data, returning: [:id, :employee_code, :country])

  inserted.rows.each do |id, _code, country|
    config = COUNTRIES_WITH_CURRENCIES[country]
    min_s, max_s = config[:salary_range]

    hire_date = employees_data.find { |e| e[:employee_code] == _code }&.dig(:hire_date) || 2.years.ago.to_date

    initial_salary = rand(min_s..max_s).to_f
    current_salary = (initial_salary * rand(1.0..1.35)).round(2)

    if rand < 0.6
      salaries_data << {
        employee_id: id,
        amount: initial_salary,
        currency: config[:currency],
        effective_from: hire_date,
        effective_to: 1.year.ago.to_date,
        notes: "Initial salary on joining",
        created_at: now,
        updated_at: now
      }
      salaries_data << {
        employee_id: id,
        amount: current_salary,
        currency: config[:currency],
        effective_from: 1.year.ago.to_date + 1.day,
        effective_to: nil,
        notes: "Annual review increment",
        created_at: now,
        updated_at: now
      }
    else
      salaries_data << {
        employee_id: id,
        amount: current_salary,
        currency: config[:currency],
        effective_from: hire_date,
        effective_to: nil,
        notes: "Salary on joining",
        created_at: now,
        updated_at: now
      }
    end
  end

  Salary.insert_all(salaries_data) if salaries_data.any?

  print "  Batch #{batch + 1}/#{TOTAL_EMPLOYEES / BATCH_SIZE} done (#{employee_counter} employees)\r"
  $stdout.flush
end

puts "\nDone! Seeded #{Employee.count} employees and #{Salary.count} salary records."
