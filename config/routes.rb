Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "tools#validation_text"
  
  # Tools routes
  post "tools/generate_validation_text", to: "tools#generate_validation_text"
  get "tools/flexible_data", to: "tools#flexible_data"
  post "tools/generate_flexible_data", to: "tools#generate_flexible_data"
  get "tools/simple_dummy", to: "tools#simple_dummy"
  post "tools/generate_name", to: "tools#generate_name"
  post "tools/generate_email", to: "tools#generate_email"
  post "tools/generate_phone", to: "tools#generate_phone"
  post "tools/generate_address", to: "tools#generate_address"
  get "tools/test_class_analysis", to: "tools#test_class_analysis"
  post "tools/analyze_boundary", to: "tools#analyze_boundary"
end
