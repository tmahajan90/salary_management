require "rails_helper"

RSpec.describe "Api::V1::Salaries", type: :request do
  let(:json) { JSON.parse(response.body) }
  let(:employee) { create(:employee) }

  describe "GET /api/v1/employees/:employee_id/salaries" do
    before { create_list(:salary, 3, employee: employee) }

    it "returns all salaries for the employee" do
      get "/api/v1/employees/#{employee.id}/salaries"
      expect(response).to have_http_status(:ok)
      expect(json["salaries"].size).to eq(3)
    end
  end

  describe "POST /api/v1/employees/:employee_id/salaries" do
    let(:valid_params) do
      {
        salary: {
          amount: 1_500_000,
          currency: "INR",
          effective_from: "2024-04-01",
          notes: "Promotion increment"
        }
      }
    end

    it "creates a salary record" do
      expect {
        post "/api/v1/employees/#{employee.id}/salaries", params: valid_params
      }.to change(employee.salaries, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(json["salary"]["amount"]).to eq(1_500_000.0)
    end

    it "closes the previous current salary" do
      previous = create(:salary, employee: employee,
                        effective_from: 2.years.ago.to_date,
                        effective_to: nil)

      post "/api/v1/employees/#{employee.id}/salaries",
           params: { salary: { amount: 2_000_000, currency: "INR", effective_from: Date.today.to_s } }

      expect(previous.reload.effective_to).to be_present
    end

    it "returns 422 for invalid salary data" do
      post "/api/v1/employees/#{employee.id}/salaries",
           params: { salary: { amount: -500, currency: "INR", effective_from: "2024-01-01" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 404 for unknown employee" do
      post "/api/v1/employees/9999999/salaries", params: valid_params
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/v1/employees/:employee_id/salaries/:id" do
    let!(:salary) { create(:salary, employee: employee) }

    it "deletes the salary record" do
      expect {
        delete "/api/v1/employees/#{employee.id}/salaries/#{salary.id}"
      }.to change(Salary, :count).by(-1)

      expect(response).to have_http_status(:ok)
    end
  end
end
