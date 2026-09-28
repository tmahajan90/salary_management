require "rails_helper"

RSpec.describe "Api::V1::Employees", type: :request do
  let(:json) { JSON.parse(response.body) }

  describe "GET /api/v1/employees" do
    before { create_list(:employee, 5) }

    it "returns 200 with paginated results" do
      get "/api/v1/employees"
      expect(response).to have_http_status(:ok)
      expect(json["employees"].size).to eq(5)
      expect(json["meta"]["total"]).to eq(5)
    end

    it "filters by department" do
      create(:employee, department: "HR")
      get "/api/v1/employees", params: { department: "HR" }
      expect(json["employees"].all? { |e| e["department"] == "HR" }).to be true
    end

    it "filters by country" do
      create(:employee, country: "United States")
      get "/api/v1/employees", params: { country: "United States" }
      expect(json["employees"].all? { |e| e["country"] == "United States" }).to be true
    end

    it "filters by status" do
      create(:employee, :inactive)
      get "/api/v1/employees", params: { status: "inactive" }
      expect(json["employees"].all? { |e| e["status"] == "inactive" }).to be true
    end

    it "searches by name" do
      unique_emp = create(:employee, first_name: "Zephyros")
      get "/api/v1/employees", params: { q: "Zephyros" }
      expect(json["employees"].map { |e| e["id"] }).to include(unique_emp.id)
    end

    it "paginates results" do
      get "/api/v1/employees", params: { per_page: 3, page: 1 }
      expect(json["employees"].size).to eq(3)
      expect(json["meta"]["per_page"]).to eq(3)
    end
  end

  describe "GET /api/v1/employees/:id" do
    let(:employee) { create(:employee, :with_salary) }

    it "returns the employee with salary history" do
      get "/api/v1/employees/#{employee.id}"
      expect(response).to have_http_status(:ok)
      expect(json["employee"]["id"]).to eq(employee.id)
      expect(json["employee"]["salary_history"]).to be_an(Array)
    end

    it "returns 404 for unknown employee" do
      get "/api/v1/employees/9999999"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/employees" do
    let(:valid_params) do
      {
        employee: {
          employee_code: "EMP-TEST-01",
          first_name: "Alice",
          last_name: "Smith",
          email: "alice.smith@test.com",
          department: "Engineering",
          job_title: "Software Engineer",
          country: "India",
          hire_date: "2024-01-15",
          status: "active"
        }
      }
    end

    it "creates a new employee" do
      expect {
        post "/api/v1/employees", params: valid_params
      }.to change(Employee, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(json["employee"]["email"]).to eq("alice.smith@test.com")
    end

    it "returns 422 for invalid data" do
      post "/api/v1/employees", params: { employee: { first_name: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json["errors"]).to be_present
    end
  end

  describe "PATCH /api/v1/employees/:id" do
    let(:employee) { create(:employee) }

    it "updates the employee" do
      patch "/api/v1/employees/#{employee.id}", params: { employee: { job_title: "Staff Engineer" } }
      expect(response).to have_http_status(:ok)
      expect(json["employee"]["job_title"]).to eq("Staff Engineer")
    end
  end

  describe "DELETE /api/v1/employees/:id" do
    let(:employee) { create(:employee) }

    it "deactivates the employee instead of deleting" do
      delete "/api/v1/employees/#{employee.id}"
      expect(response).to have_http_status(:ok)
      expect(employee.reload.status).to eq("inactive")
    end
  end
end
