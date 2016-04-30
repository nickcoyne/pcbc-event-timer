PcbcEventTimer::Application.routes.draw do
  resources :athletes
  resources :events do
    resources :stages
    get :import_results, on: :member
  end
  resources :stages do
    get :import_results, on: :member
  end
  resources :stage_results

  root to: 'events#index'
end
