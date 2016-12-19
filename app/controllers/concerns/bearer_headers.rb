# See http://self-issued.info/docs/draft-ietf-oauth-v2-bearer.html#authn-header
module BearerHeaders
  extend ActiveSupport::Concern

  WWW_AUTHENTICATE = 'WWW-Authenticate'

  included do
    def auth0_unauthenticated(decode_error)
      { WWW_AUTHENTICATE => from_error(decode_error, 'auth0') }
    end

    def api_unauthenticated(decode_error)
      { WWW_AUTHENTICATE => from_error(decode_error, 'api') }
    end

    def api_unauthorized
      { WWW_AUTHENTICATE => from_error('insufficient scope', 'api') }
    end

    private

    def from_error(decode_error, realm)
      scheme = 'Bearer'
      realm = "realm=\"#{realm}\""
      error = "error='invalid_token'"
      desc  = "error_description=\"#{decode_error}\""
      auth_params = [realm, error, desc].join(', ')
      [scheme, auth_params].join(' ')
    end
  end
end
