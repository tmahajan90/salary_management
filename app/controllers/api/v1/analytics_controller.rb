module Api
  module V1
    class AnalyticsController < BaseController
      def summary
        total_employees = Employee.count
        active_employees = Employee.active.count

        render json: {
          total_employees: total_employees,
          active_employees: active_employees,
          inactive_employees: total_employees - active_employees,
          employees_with_salary: Salary.current.count,
          departments_count: Employee.distinct.count(:department),
          countries_count: Employee.distinct.count(:country),
          recent_hires: Employee.where("hire_date >= ?", 90.days.ago).count
        }
      end

      def by_department
        data = Employee.active
                       .joins("LEFT JOIN salaries ON salaries.employee_id = employees.id AND salaries.effective_to IS NULL")
                       .group(:department)
                       .select(
                         "department",
                         "COUNT(DISTINCT employees.id) AS headcount",
                         "ROUND(AVG(salaries.amount), 2) AS avg_salary",
                         "MIN(salaries.amount) AS min_salary",
                         "MAX(salaries.amount) AS max_salary"
                       )
                       .map do |row|
                         {
                           department: row.department,
                           headcount: row.headcount.to_i,
                           avg_salary: row.avg_salary&.to_f,
                           min_salary: row.min_salary&.to_f,
                           max_salary: row.max_salary&.to_f
                         }
                       end

        render json: { by_department: data }
      end

      def by_country
        data = Employee.active
                       .joins("LEFT JOIN salaries ON salaries.employee_id = employees.id AND salaries.effective_to IS NULL")
                       .group(:country)
                       .select(
                         "country",
                         "COUNT(DISTINCT employees.id) AS headcount",
                         "ROUND(AVG(salaries.amount), 2) AS avg_salary",
                         "MIN(salaries.amount) AS min_salary",
                         "MAX(salaries.amount) AS max_salary"
                       )
                       .map do |row|
                         {
                           country: row.country,
                           headcount: row.headcount.to_i,
                           avg_salary: row.avg_salary&.to_f,
                           min_salary: row.min_salary&.to_f,
                           max_salary: row.max_salary&.to_f
                         }
                       end

        render json: { by_country: data }
      end

      def salary_distribution
        amounts = Salary.current.pluck(:amount).map(&:to_f)
        render json: { distribution: build_distribution_buckets(amounts), total: amounts.size }
      end

      def recent_changes
        changes = Salary.includes(:employee)
                        .order(created_at: :desc)
                        .limit(20)
                        .map do |s|
                          {
                            employee_id: s.employee_id,
                            employee_name: s.employee.full_name,
                            employee_code: s.employee.employee_code,
                            department: s.employee.department,
                            amount: s.amount.to_f,
                            currency: s.currency,
                            effective_from: s.effective_from,
                            changed_at: s.created_at
                          }
                        end

        render json: { recent_changes: changes }
      end

      private

      def build_distribution_buckets(amounts)
        return [] if amounts.empty?

        min = amounts.min
        max = amounts.max
        range = max - min
        bucket_size = [range / 10.0, 1].max

        buckets = {}
        amounts.each do |amount|
          bucket_start = ((amount - min) / bucket_size).floor * bucket_size + min
          label = "#{fmt(bucket_start)}-#{fmt(bucket_start + bucket_size)}"
          buckets[bucket_start] ||= { range: label, from: bucket_start, to: bucket_start + bucket_size, count: 0 }
          buckets[bucket_start][:count] += 1
        end

        buckets.values.sort_by { |b| b[:from] }
      end

      def fmt(amount)
        if amount >= 1_000_000
          "#{(amount / 1_000_000.0).round(1)}M"
        elsif amount >= 1_000
          "#{(amount / 1_000.0).round(0).to_i}K"
        else
          amount.to_i.to_s
        end
      end
    end
  end
end
