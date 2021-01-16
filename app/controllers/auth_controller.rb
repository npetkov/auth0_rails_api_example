# frozen_string_literal: true

class AuthController < ActionController::API
  include ActionController::Cookies
  include BearerHeaders

  def token
    auth_header = request.headers['Authorization'] || ''
    auth_token_string = auth_header.split.last || cookies[:auth_token]

    begin
      api_token = create_api_token auth_token_string
      render json: { api_token: api_token }, status: 201
    rescue CsrfTokenInvalid, JWT::DecodeError => e
      response.headers.merge!(auth0_unauthenticated(e))
      head 401
    end
  end

  private

  class CsrfTokenInvalid < StandardError
  end

  def create_api_token(auth_token_string)
    auth_token = decode_auth_token auth_token_string
    validate_csrf_token! auth_token
    encode_api_token auth_token
  end

  def validate_csrf_token!(auth_token)
    header_token = request.headers['X-API-CSRF-TOKEN']
    digest = OpenSSL::HMAC.hexdigest('SHA256', Rails.application.credentials.auth_client_secret, auth_token.to_s)
    raise CsrfTokenInvalid, 'Can\'t verify API CSRF token' unless header_token == digest
  end

  def decode_auth_token(token)
    options = { algorithm: 'HS256' }
    decoded_token = JWT.decode(token, Rails.application.credentials.auth_client_secret, true, options)
    decoded_token[0]
  end

  def encode_api_token(auth_token)
    JWT.encode(
      {
        iat: Time.now.to_i,
        exp: [Time.now.to_i + 10.minutes.to_i, auth_token['exp']].min,
        aud: auth_token['aud'],
        sub: auth_token['user_id'],
        scopes: auth_token['scopes'] || {}
      }, Rails.application.credentials.api_secret, 'HS256'
    )
  end
end
