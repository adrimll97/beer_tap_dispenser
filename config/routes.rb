Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :dispensers, only: %i[create] do
        put 'status', on: :member
        get 'spending', on: :member
      end
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
