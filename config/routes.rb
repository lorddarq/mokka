Mokka::Application.routes.draw do
  scope "mokka" do
    resources :pages
    get :widget, to: 'pages#widget'
    get :debug, to: 'pages#debug'
    root "pages#index"
  end
end
