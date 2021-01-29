# frozen_string_literal: true

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
      aud: Rails.application.credentials.api_identifier,
      verify_aud: true,
      verify_iat: true,
      algorithm: 'HS256'
    }
    begin
      @token = JWT.decode(token, Rails.application.credentials.api_secret, true, options)[0]
    rescue JWT::DecodeError => e
      response.headers.merge!(api_unauthenticated(e))
      head 401
    end
  end

  def pundit_user
    @token
  end

  rescue_from Pundit::NotAuthorizedError do
    head 403
  end
end
