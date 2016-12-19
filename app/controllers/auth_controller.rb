class AuthController < ActionController::API
  include ActionController::Cookies
  include BearerHeaders

  def token
    auth_header = request.headers['Authorization'] || ''
    token = auth_header.split.last || cookies[:auth_token]

    begin
      auth_token = decode_auth_token token
      validate_csrf_token! auth_token

      api_token  = encode_api_token auth_token
      render json: { api_token: api_token }, status: 201
    rescue CsrfTokenInvalid, JWT::DecodeError => e
      response.headers.merge!(auth0_unauthenticated(e))
      head 401
    end
  end

  private

  class CsrfTokenInvalid < StandardError
  end

  def validate_csrf_token!(auth_token)
    header_token = request.headers['X-API-CSRF-TOKEN']
    digest = OpenSSL::HMAC.hexdigest('SHA256', "#{ENV['AUTH_CLIENT_SECRET']}", auth_token.to_s)
    raise CsrfTokenInvalid, 'Can\'t verify API CSRF token' unless header_token == digest
  end

  def decode_auth_token(token)
    options = { algorithm: 'HS256' }
    decoded_token = JWT.decode(token, ENV['AUTH_CLIENT_SECRET'], true, options)
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
      }, ENV['API_SECRET'], 'HS256')
  end
end
