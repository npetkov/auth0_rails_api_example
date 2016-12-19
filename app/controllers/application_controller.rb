class ApplicationController < ActionController::API
  include Pundit
  include BearerHeaders

  before_action :verify_token
  after_action  :verify_authorized
  after_action  :verify_policy_scoped, except: [:create]

  def verify_token
    auth_header = request.headers['Authorization'] || ''
    token = auth_header.split.last
    options = {
        verify_iat: true,
        algorithm: 'HS256'
    }
    begin
      @token = JWT.decode(token, ENV['API_SECRET'], true, options)[0]
    rescue JWT::DecodeError => e
      response.headers.merge!(api_unauthenticated(e))
      head 401
    end
  end

  def pundit_user
    @token
  end

  rescue_from Pundit::NotAuthorizedError do
    response.headers.merge!(api_unauthorized)
    head 403
  end
end
