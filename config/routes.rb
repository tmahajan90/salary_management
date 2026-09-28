Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :employees do
        resources :salaries, only: [:index, :create, :update, :destroy]
      end

      get "analytics/summary", to: "analytics#summary"
      get "analytics/by_department", to: "analytics#by_department"
      get "analytics/by_country", to: "analytics#by_country"
      get "analytics/salary_distribution", to: "analytics#salary_distribution"
      get "analytics/recent_changes", to: "analytics#recent_changes"

      get "meta/filters", to: "meta#filters"
    end
  end
end
