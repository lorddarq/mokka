Mokka::Application.routes.draw do
  scope "mokka" do
    resources :pages
    get :widget, to: 'pages#widget'
    get :debug, to: 'pages#debug'
    get :tablet, to: 'pages#tablet'
    get :phone, to: 'pages#phone'
    root "pages#index"
  end
end
