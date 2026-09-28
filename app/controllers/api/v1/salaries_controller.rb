module Api
  module V1
    class SalariesController < BaseController
      before_action :set_employee

      def index
        salaries = @employee.salaries.ordered
        render json: { salaries: salaries.map { |s| serialize_salary(s) } }
      end

      def create
        salary = @employee.salaries.create!(salary_params)
        render json: { salary: serialize_salary(salary) }, status: :created
      end

      def update
        salary = @employee.salaries.find(params[:id])
        salary.update!(salary_params)
        render json: { salary: serialize_salary(salary) }
      end

      def destroy
        salary = @employee.salaries.find(params[:id])
        salary.destroy!
        render json: { message: "Salary record deleted" }
      end

      private

      def set_employee
        @employee = Employee.find(params[:employee_id])
      end

      def salary_params
        params.require(:salary).permit(:amount, :currency, :effective_from, :effective_to, :notes)
      end

      def serialize_salary(salary)
        {
          id: salary.id,
          employee_id: salary.employee_id,
          amount: salary.amount.to_f,
          currency: salary.currency,
          effective_from: salary.effective_from,
          effective_to: salary.effective_to,
          notes: salary.notes,
          created_at: salary.created_at
        }
      end
    end
  end
end
