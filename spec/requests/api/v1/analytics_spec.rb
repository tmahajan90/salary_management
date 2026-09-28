require "rails_helper"

RSpec.describe "Api::V1::Analytics", type: :request do
  let(:json) { JSON.parse(response.body) }

  before do
    emp1 = create(:employee, department: "Engineering", country: "India", status: "active")
    emp2 = create(:employee, department: "HR", country: "United States", status: "active")
    create(:employee, status: "inactive")
    create(:salary, employee: emp1, amount: 1_200_000, currency: "INR", effective_from: 1.year.ago.to_date)
    create(:salary, employee: emp2, amount: 80_000, currency: "USD", effective_from: 1.year.ago.to_date)
  end

  describe "GET /api/v1/analytics/summary" do
    it "returns headcount stats" do
      get "/api/v1/analytics/summary"
      expect(response).to have_http_status(:ok)
      expect(json["total_employees"]).to eq(3)
      expect(json["active_employees"]).to eq(2)
      expect(json["inactive_employees"]).to eq(1)
      expect(json["employees_with_salary"]).to eq(2)
    end
  end

  describe "GET /api/v1/analytics/by_department" do
    it "returns department breakdown" do
      get "/api/v1/analytics/by_department"
      expect(response).to have_http_status(:ok)
      departments = json["by_department"].map { |d| d["department"] }
      expect(departments).to include("Engineering", "HR")
    end

    it "includes headcount and salary stats per department" do
      get "/api/v1/analytics/by_department"
      eng = json["by_department"].find { |d| d["department"] == "Engineering" }
      expect(eng["headcount"]).to eq(1)
      expect(eng["avg_salary"]).to be_present
    end
  end

  describe "GET /api/v1/analytics/by_country" do
    it "returns country breakdown" do
      get "/api/v1/analytics/by_country"
      expect(response).to have_http_status(:ok)
      countries = json["by_country"].map { |d| d["country"] }
      expect(countries).to include("India", "United States")
    end
  end

  describe "GET /api/v1/analytics/salary_distribution" do
    it "returns salary distribution buckets" do
      get "/api/v1/analytics/salary_distribution"
      expect(response).to have_http_status(:ok)
      expect(json["distribution"]).to be_an(Array)
      expect(json["total"]).to eq(2)
    end
  end

  describe "GET /api/v1/analytics/recent_changes" do
    it "returns recent salary changes" do
      get "/api/v1/analytics/recent_changes"
      expect(response).to have_http_status(:ok)
      expect(json["recent_changes"]).to be_an(Array)
      expect(json["recent_changes"].first).to have_key("employee_name")
    end
  end
end
