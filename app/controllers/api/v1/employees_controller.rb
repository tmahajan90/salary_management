module Api
  module V1
    class EmployeesController < BaseController
      before_action :set_employee, only: [:show, :update, :destroy]

      def index
        employees = Employee.all
        employees = employees.search(params[:q]) if params[:q].present?
        employees = employees.by_department(params[:department]) if params[:department].present?
        employees = employees.by_country(params[:country]) if params[:country].present?
        employees = employees.where(status: params[:status]) if params[:status].present?

        employees = apply_sort(employees)
        total = employees.count

        employees = employees.page(params[:page]).per(params[:per_page] || 25)

        render json: {
          employees: employees.map { |e| serialize_employee(e) },
          meta: {
            total: total,
            page: employees.current_page,
            per_page: employees.limit_value,
            total_pages: employees.total_pages
          }
        }
      end

      def show
        render json: { employee: serialize_employee(@employee, include_salary_history: true) }
      end

      def create
        employee = Employee.create!(employee_params)
        render json: { employee: serialize_employee(employee) }, status: :created
      end

      def update
        @employee.update!(employee_params)
        render json: { employee: serialize_employee(@employee) }
      end

      def destroy
        @employee.update!(status: "inactive")
        render json: { message: "Employee deactivated" }
      end

      private

      def set_employee
        @employee = Employee.find(params[:id])
      end

      def employee_params
        params.require(:employee).permit(
          :employee_code, :first_name, :last_name, :email,
          :department, :job_title, :country, :hire_date, :status
        )
      end

      def apply_sort(scope)
        sort_column = %w[first_name last_name department country hire_date status].include?(params[:sort]) ? params[:sort] : "first_name"
        sort_dir = params[:dir] == "desc" ? "desc" : "asc"
        scope.order("#{sort_column} #{sort_dir}")
      end

      def serialize_employee(employee, include_salary_history: false)
        current = employee.current_salary
        result = {
          id: employee.id,
          employee_code: employee.employee_code,
          first_name: employee.first_name,
          last_name: employee.last_name,
          full_name: employee.full_name,
          email: employee.email,
          department: employee.department,
          job_title: employee.job_title,
          country: employee.country,
          hire_date: employee.hire_date,
          status: employee.status,
          created_at: employee.created_at,
          current_salary: current ? serialize_salary(current) : nil
        }

        if include_salary_history
          result[:salary_history] = employee.salaries.ordered.map { |s| serialize_salary(s) }
        end

        result
      end

      def serialize_salary(salary)
        {
          id: salary.id,
          amount: salary.amount.to_f,
          currency: salary.currency,
          effective_from: salary.effective_from,
          effective_to: salary.effective_to,
          notes: salary.notes
        }
      end
    end
  end
end
