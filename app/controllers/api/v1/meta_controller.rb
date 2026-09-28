module Api
  module V1
    class MetaController < BaseController
      def filters
        render json: {
          departments: Employee.distinct.order(:department).pluck(:department),
          countries: Employee.distinct.order(:country).pluck(:country),
          currencies: Salary::CURRENCIES,
          statuses: Employee::STATUSES
        }
      end
    end
  end
end
