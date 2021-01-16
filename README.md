# README

This is a sample Rails 6 API project demonstrating API authentication with a JWT
token issued by a third party identity provider. I'm using
[auth0](https://auth0.com/), but the same principles apply for any OAuth
provider, so feel free to change your configuration accordingly. Please note
that this project is meant as a proof of concept and shouldn't be used for any
serious purposes without further consideration.

A separate [project](https://github.com/npetkov/auth0_rails_frontend_example)
provides a very basic implementation of an API client (front end) that
complements this one. I suggest checking it out and reading its documentation as
well.

The motivation behind this project is to provide a brief, concise introduction
to JWT authentication using Rails. I've read through a lot of resources covering
different aspects of the topic so I decided to put them together in one working
example.
## Installation

Clone the repo and run the usual `bundle install`. I'm using Ruby 3.0.0 and
can't guarantee that everything will work as expected with earlier versions.

To launch the server, use `bin/rails s -p 3001`. I prefer using port 3001 as I
normally have another server listening to port 3000. Below, I'll assume the
server is running at `http://localhost:3001`.

## Auth0 and API secret configuration

The project uses the Rails 6 encrypted credentials scheme. The project relies on
the following credentials being present:

* __api_id__ - seems unused, can be anything
* __api_secret__ - a secret used to sign JWT tokens issued by the API. A secret
can be easily generated via `rake secret`.
* __auth_client_secret__ - this key can be found under 'Applications -> _(your
  auth0 application name)_ -> Settings -> Client Secret' at the auth0 dashboard.
## CORS

The server is configured to allow CORS requests from `http://localhost:3000` by
default. This can be changed in `config/initializers/cors.rb`.

## Authentication flow

In order to obtain an API token, a client should supply a valid JWT issued by
auth0. The complete flow is:

1. Issue a `POST` request to `http://localhost:3001/auth/token`, with the auth0
   token in a cookie named `auth_token` or as `Authorization` header.
2. The server verifies the following:
    1. The auth0 token provided, via the shared secret. Upon successful
      verification, the response is a simple JSON object with a new API token
      which is valid for 10 minutes. Otherwise, the response will be 401 (no
      error messages etc. for now), including a `WWW-Authenticate` header
      denoting that the provided auth0 token isn't valid.
    2. A `X-API-CSRF-TOKEN` header, preventing CSRF attacks from issuing API
      tokens. The header contains a digest that can only be calculated
      server-side, either by the API or the front-end application.
3. The client supplies the newly generated token with every request via
    `Authorization` header.

## Authorization

I've also included [Pundit](https://github.com/elabs/pundit) in the project to
demonstrate how per-endpoint authorization can be achieved via JWT (please note
that this doesn't include _per-resource_ authorization, which I hope to cover in
the future). The prerequisite is that the JWT supplied to `auth/token` has a
`scopes` field, listing the allowed actions for every API endpoint. Consider
this example:

```json
  {
    "iat": 1481815155,
    "exp": 1481815755,
    "aud": "2IYaN3ycGIs9JFcqDDtRCrx3P4odPJCi",
    "sub": "auth0|584ec9c7c641b4f41364bccf",
    "scopes": {
      "actions": {
        "notes": [
          "index",
          "create"
        ]
      }
    }
  }
```

In the case of auth0, this can be achieved by adding the `scopes` object to the
`app_metadata` of the user object, resulting in a raw user object looking like
this (most of the data left out for brevity):

```json
  {
    "app_metadata": {
      "scopes": {
        "actions": {
          "notes": [
            "index",
            "create"
          ]
        }
      }
    }
  }
```

Note that the `notes` field corresponds to the single data-endpoint defined in
the API, which is `/notes`. So as long as the token provided contains a
whitelist of all actions allowed on that endpoint for the particular user,
Pundit will take care of the rest. The implementation is extremely basic and can
be found in `app/policies/action_scope.rb`.

If you're using [Lock](https://github.com/auth0/lock) for sign in, the following
options object will result in the `scopes` field being rendered at the root of
the auth0 JWT:

```javascript
  options = {
    auth: {
      params: {
        state: 'd69d13cf89c87481c67a977880f3b84ca626af25',
        scope: 'openid name email user_id scopes'
      },
    }
  }
```

## Testing

I haven't implemented any tests yet so please feel free to contribute.

## Contributing

Don't hesitate to create issues or feature requests. Any suggestions are
welcome.

## External links

Below are some authentication/authorization resources I found quite useful.

  * [OAuth2 overview by
    Google](https://developers.google.com/identity/protocols/OAuth2)
  * [OAuth2 code
    grant](http://oauthlib.readthedocs.io/en/latest/oauth2/grants/authcode.html)
  * [JWT and APIs in the auth0
    blog](https://auth0.com/blog/2014/12/02/using-json-web-tokens-as-api-keys/)
  * [JWT vulnerabilities in the auth0
    blog](https://auth0.com/blog/critical-vulnerabilities-in-json-web-token-libraries/)
  * [The go-to JWT ruby library, with a nice claims
    overview/examples](https://github.com/jwt/ruby-jwt)
  * [The state parameter in
    OAuth2](http://www.twobotechnologies.com/blog/2014/02/importance-of-state-in-oauth2.html)
  * [The WWW-Authenticate Response Header
    Field](http://self-issued.info/docs/draft-ietf-oauth-v2-bearer.html#authn-header)
  * [CSRF
    Tokens](https://www.owasp.org/index.php/Cross-Site_Request_Forgery_(CSRF)_Prevention_Cheat_Sheet#Synchronizer_.28CSRF.29_Tokens)
  * [Cookies and CORS](https://quickleft.com/blog/cookies-with-my-cors/)
  * [OPTIONS requests in
    Rails](https://bibwild.wordpress.com/2014/10/07/catching-http-options-request-in-a-rails-app/)
  * [Some useful CORS practices for Rails
    projects](https://gist.github.com/dhoelzgen/cd7126b8652229d32eb4)

## Disclaimer

I am not part of the auth0 team nor am I affiliated to auth0 in any way. I'm
using auth0 for the sole purpose of demonstrating API authorization via JWT.

## License

This product is licensed under the [MIT
License](https://github.com/npetkov/auth0_rails_api_example/blob/dev/LICENSE).
