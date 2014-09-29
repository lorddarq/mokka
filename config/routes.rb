Mokka::Application.routes.draw do
  scope "mokka" do
    resources :pages
    get :widget, to: 'pages#widget'
    get :tablet, to: 'pages#tablet'
    get :phone, to: 'pages#phone'
    get :debug, to: 'pages#debug'
    get :debug_tablet, to: 'pages#debug_tablet'
    get :debug_phone, to: 'pages#debug_phone'
    root "pages#index"
  end
end
