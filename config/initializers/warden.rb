Rails.configuration.middleware.use RailsWarden::Manager do |manager|
  manager.default_strategies :cookie_with_access_token
  manager.failure_app = SessionsController
end

Warden::Strategies.add(:cookie_with_access_token) do
  def authenticate!
    access_token = LamAuth.access_token_from_cookie(request.cookies[LamAuth.cookie_id])
    access_token ? success!(User.find_by_access_token(access_token)) : fail
  end
end
