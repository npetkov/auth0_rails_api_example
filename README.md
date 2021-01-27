# README

This is a sample Rails 6 API project demonstrating API authentication with a JWT
token issued by a third party identity provider. I'm using
[auth0](https://auth0.com/), but the same principles apply for any OAuth
provider, so feel free to change your configuration accordingly. Please note
that this project is meant as a proof of concept and shouldn't be used for any
serious purposes without further consideration.

A separate [project](https://github.com/npetkov/auth0_rails_frontend_example)
provides a very basic implementation of an API client (front end) that
complements this one. Although both projects reside in separate repositories,
they depend on each other and are quite useless considered on their own.

The motivation behind this project is to provide a brief, concise introduction
to JWT authentication using Rails. I've read through a lot of resources covering
different aspects of the topic so I decided to put them together in one working
example.

Even though the documentation at the Auth0 site is quite extensive, it can
quickly become overwhelming due to the huge amount of configuration options and
use cases it covers. Accomplishing a seemingly easy task - authenticating
against an API using OAuth and JWT - has proved to be quite challenging,
especially considering some peculiarities of the Ruby gems involved.

In the following sections, I'll try to summarize all the steps required to get
this API project up and running. Of course, having set up Ruby, Rails and the
required Auth0 applications means that setting up the front end project will be
a much quicker task.

## Installing `rbenv` and Ruby

My preferred method for installing Ruby is via `rbenv`. Please consult the
[readme file](https://github.com/rbenv/rbenv) for instructions how to install
`rbenv`, `rbenv-build` and Ruby on your operating system. Below are the
steps needed on Ubuntu.

* install `git`, `gcc` and `make` if not already present
* clone the repo:

`git clone https://github.com/rbenv/rbenv.git ~/.rbenv`

* compile "dynamic bash extension":

`cd ~/.rbenv && src/configure && make -C src`

* set `PATH`:

`echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc`

* run the init script:

`~/.rbenv/bin/rbenv init`

* add output from previous step to shell profile (`.bashrc`):

`echo 'eval "$(rbenv init -)"' >> ~/.bashrc`

* reload bash profile:

`source ~/.bashrc`

* install `rbenv-build`:

``` bash
mkdir -p "$(rbenv root)"/plugins
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
```

* List Ruby versions available for install via `rbenv install -l`:

```
2.5.8
2.6.6
2.7.2
3.0.0
...

Only latest stable releases for each Ruby implementation are shown.
Use 'rbenv install --list-all / -L' to show all local versions.
```

* Install your preferred Ruby version (I'm using 3.0.0 for this project):

`rbenv install 3.0.0`

* It is possible that the compilation process complains about missing
dependencies. The script will give useful hints how to install them:

``` bash
sudo apt install libssl-dev zlib1g-dev
```

* After installing the missing dependencies and re-running the installation
  script, set the newly built Ruby version as the default:

`rbenv global 3.0.0`

You should see a similar output when running `ruby -v`:

```
ruby 3.0.0p0 (2020-12-25 revision 95aff21468) [x86_64-linux]
```

## Installing Rails

* Start by updating RubyGems. This will output a rather verbose changelog, also
  stating that the `gem`, `bundle` and `bundler` binaries have been installed.

`gem update --system --no-doc`

* Install Rails. On some platforms, gems like `nokogiri` may fail to install
  from the get go as they rely on native extensions which may require
  platform-specific tweaks to compile. These issues are rather common and
  there are a lot of resources online explaining how to resolve them.

`gem install rails`

* When finished, double-check: `gem info rails`

### Setting up an Auth0 application and API

Signing up for an Auth0 account is rather straightforward, but there is one
caveat: use a regular username/password to register if you plan on adding social
integrations (e.g. Google oauth) to your account later. Signing up using "sign
in with Google" and creating a Google "social connection" after that has proved
troublesome for me in the past.

There are several things which must be configured in the dashboard: a new
application, a new API and user groups/permissions.

### Creating a new application

Choose "Applications" in the sidebar and then proceed with creating a new
application. The following configuration is required for the new app.

* Name - e.g. "Rails Application"
* Application Type - choose "Regular Web Applications"
* Navigate away from "Quick start" to the "Settings" tab
* In the "Allowed callback URLs" text area, enter
  `http://localhost:3000/auth/auth0/callback`

  If you plan on running your (local) server at a different port, change it
  accordingly.
* In the "Allowed logout URLs" text area, enter `http://localhost:3000`
* Enter the same URL in "Allowed Web Origins" and "Allowed Origins (CORS)"
* Navigate to the bottom of the page and choose "Show Advanced Settings"
* In the OAuth tab, change the "JsonWebToken Signature Algorithm" to `HS256`
* Save your changes.

### Creating a new API

From the sidebar, choose "APIs" and proceed by clicking the "Create API" button
on the far right. The following configuration must be applied:

* Name - e.g. "Rails API"
* Identifier - can be anything, but should preferably be an URL, as the hint
  suggests. This identifier will appear in the `aud` claim of the access tokens
  issued by Auth0 and used to access the API
* Signing algorithm: choose `HS256`
* Navigate away from the "Quick Start" tab to "Settings"
* Enable both toggles under "RBAC Setting" - "Enable RBAC" and "Add Permissions in
  the Access Token" and save your changes
* In the "Permissions" tab, create two new permissions - `index:notes` and
  `create:notes`. Those are the only actions that the single Rails API endpoint
  exposes.
* In the "Machine to Machine Applications" tab, enable the toggle next to the
  application you created in the section above (e.g. Rails Application).
* Click on the arrow next to the toggle and select both permissions you just
  created.
* Click on update and confirm that you create a grant with all available scopes.

### Creating user roles

* Choose "Users and Roles" from the side bar
* Create two new roles - e.g. "User" and "Administrator", selecting different
  permissions accordingly
* If you have already registered/created some users, you can proceed with
  assigning them some of the newly created roles.

## Creating a social connection - allowing "sign in with Google" for your application

This step is optional, but it has saved me a lot of time during development.
From the "Connections" menu in the sidebar, choose "Social" and then add
"Google/Gmail". The
[documentation](https://auth0.com/docs/connections/social/google?_ga=2.151122937.1511962912.1611782875-1030349018.1611782874)
Auth0 provides on the topic is quite adequate and I refer you to the steps
described there for creating the configuration needed on the Google side of the
fence.

Once you're done, double check that the connection is enabled for the new "Rails
Application" created in the section above.

## Project setup

Clone the repo and run the usual `bundle install`. I'm using Ruby 3.0.0 and
can't guarantee that everything will work as expected with earlier versions.

If you encounter and error with the `sqlite3` gem installation, follow the hints
in the error description. Under Ubuntu, the following package must be installed:

``` bash
sudo apt install libsqlite3-dev
```

Once all gems have been successfully installed, run `bin/setup`. This will
ensure everything is properly set up and you can launch the application server.

To launch the server, use `bin/rails s -p 3001`. I prefer using port 3001 as I
normally have another server listening to port 3000. Below, I'll assume the
server is running at `http://localhost:3001`.

## Auth0 and API secret configuration

The project uses the Rails 6 encrypted credentials scheme. The project relies on
the following credentials being present:

* __api_secret__ - this is the value used to sign the JWT tokens which API will
  use for authentication. The value must be copied from the "Signing Secret"
  (read-only) input field in the "Token Settings" section of your Auth0 API.

In order to edit the Rails application credentials, run `bin/rails credentials:edit`
in the project root. If Rails complains about an unset `EDITOR` environmental
variable, append one to your shell profile and then source it to apply the
changes:

``` bash
echo 'export EDITOR=vim' >> ~/.bashrc
source ~/.bashrc
```

Please note that the master key used to encrypt the credentials is not under
version control. If you lose it, you'll have to recreate the credentials store.

## CORS

The server is configured to allow CORS requests from `http://localhost:3000` by
default. This can be changed in `config/initializers/cors.rb`.

## Authentication flow

The API authentication relies solely on an `Authorization` header, which must
be. The current implementation of the verification hook checks verifies only the
"issued at" claim (beyond the token signature).

``` ruby
before_action :verify_token
after_action  :verify_authorized

def verify_token
  auth_header = request.headers['Authorization'] || ''
  token = auth_header.split.last
  options = {
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
```

## Authorization

I've also included [Pundit](https://github.com/elabs/pundit) in the project to
demonstrate how per-endpoint authorization can be achieved via JWT. Let's take a
look at an (decoded) API access token issued by Auth0:

``` json
{
  "iss": "https://<<tenant>>.auth0.com/",
  "sub": "google-oauth2|123456",
  "aud": [
    "<<api-identifier>>"
  ],
  "iat": 1611689366,
  "exp": 1611775766,
  "azp": "<<application-identifier>>",
  "scope": "openid profile email index:notes create:notes",
  "permissions": [
    "create:notes",
    "index:notes"
  ]
}
```

As consequence of enabling RBAC and toggling the "Add Permissions in the Access
Token" switch for the Auth0 API, the issued token contains all the permissions
that the current user (denoted in the `sub` claim) has been granted.

Note that the `scopes` claim contains the scopes (permissions) that have been
requested during the authorization phase. The actual permissions granted to the
used and listed in the `permissions` claim may be restricted, depending on the
role the user has been assigned. In order to achieve this, you have to define a
[rule](https://auth0.com/docs/architecture-scenarios/spa-api/part-2#create-a-rule-to-validate-token-scopes) in the Auth0 dashboard.

In the `ActionScope` class, the permission provided in the token are parsed into
a map, which can then be used together with some Pundit magic to provide
authorization to the API endpoint(s).

``` ruby
def map_permissions
  hash = Hash.new { |map, key| map[key] = [] }
  token[:permissions].each_with_object(hash) do |permission, map|
    action, resource = permission.split(':')
    map[resource] << action
  end
end
```

The final result is that API endpoints can be declared in an extremely concise manner:

``` ruby
class NotesController < ApplicationController
  def index
    notes = policy_scope Note
    authorize notes
    render json: notes.to_json, status: 200
  end

  def create
    note = Note.new
    authorize note
    note.assign_attributes(permitted_attributes(note))
    status = note.save ? 201 : 422
    render json: note.to_json, status: status
  end
end
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
    grant](https://oauthlib.readthedocs.io/en/latest/oauth2/grants/authcode.html)
  * [JWT and APIs in the auth0
    blog](https://auth0.com/blog/2014/12/02/using-json-web-tokens-as-api-keys/)
  * [JWT vulnerabilities in the auth0
    blog](https://auth0.com/blog/critical-vulnerabilities-in-json-web-token-libraries/)
  * [The go-to JWT ruby library, with a nice claims
    overview/examples](https://github.com/jwt/ruby-jwt)
  * [The WWW-Authenticate Response Header
    Field](https://self-issued.info/docs/draft-ietf-oauth-v2-bearer.html#authn-header)
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
