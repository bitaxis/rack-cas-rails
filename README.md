# rack-cas-rails

While [rbCAS/CASinoApp](http://rbcas.com) and [biola/rack-cas](https://github.com/biola/rack-cas) are both great
and wonderful, there is a gap between them.  Namely, the bits needed to enable a Rails application to use rack-cas to integrate with
CASinoApp for authentication are still missing.

This gem aims to fill in some of this void.

## Installation

Add the following to your Rails application's Gemfile:

```ruby
gem "rack-cas-rails"
```

Then run

```ruby
bundle install
```

## Requirements

The rack-cas-rails gem relies on the following:

  * A working CAS-compliant server, such as [CASinoApp](http://rbcas.com)
  * [rack-cas](https://github.com/biola/rack-cas)
  * [rails](http://rubyonrails.org/)

## Basic Usage

Having access to a working CAS-compliant server is a pre-requisite.  If you don't have access to one,
[CASinoApp](http://rbcas.com) is a simple one to set up and use, especially if you go with the
***directly on your server*** option.

Now that you have access to a CAS-compliant server, the next thing you need to do is to make your ```Rails::Application```
subclass aware of the CAS-compliant server you are integrating with by pointing out its base URL, as shown here.

Note that setting the ```@cas_server_url``` variable is important as the ```login_url``` helper will make use of it.

```ruby
# config/application.rb

require "rack-cas"
module MyGreatApplication
  class Application < Rails::Application
    # ...
    # Root URL of the CAS server
    @cas_server_url = "https://sso.example.org/"
    config.rack_cas.server_url = @cas_server_url
  end
end
```

In the simplest case, you'll want your entire application protected by authentication.  That is, unless a user has authenticated,
he can do nothing.  To do so, add the following ```before_action``` callback to your ```ApplicationController```:

```ruby
# app/controllers/application_ronctoller.rb

require "rack_cas_rails"
class ApplicationController < ActionController::Base
  # Enforce authentication for actions of this controller
  before_action :authenticate!
  # ...
end
```

The ```authenticate!``` method will check to see if a browser session is authenticated.  If it is, controller execution will continue.
Otherwise, it will render the ```public/401.html``` file if one exists, as well as return a HTTP status of 401.

At this point, if you fire up your application and use a browser to access any view of any controller subclassed from
ApplicationController, the browser will get re-directed to the CAS server's login page.

## Helper Methods

The rack-cas-rails gem also adds some helper methods:

* authenticate!
* authenticated?

You have already seen ```authenticate!``` at work.  The ```authenticated?``` helper allows your application to determin whether
a browser is authenticated or not and take appropriate action.

* login_url
* logout_url

When invoked, these two helpers will return the CAS-integrated login in and log out URLs, respectively.  They, in turn, enable you to
implement partial authentication.

## Partial Authentication

In this case, only certain portions of your application requires authentication.  For example, perhaps actions that are
*read-only* need not be protected by authentication.  To do this, change your ```ApplicationController``` as follows:

```ruby
# app/controllers/application_ronctoller.rb

require "rack_cas_rails"
class ApplicationController < ActionController::Base
  # Enforce authentication for actions of this controller
  before_action :authenticate!, except: [:index, :show]
  # ...
end
```

Now, you can enhance the usability of your application by adding a ```<div>``` container that will behave differently bepending
on the authentication status of a browser session.

```erb
<!-- views/layouts/application.html.erb -->

<!DOCTYPE html>
<html>
<head>
  <title>MyGreatApplication</title>
  <%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track' => true %>
  <%= javascript_include_tag 'application', 'data-turbolinks-track' => true %>
  <%= csrf_meta_tags %>
</head>
<body>
  <div id="header">
    <% if authenticated? %>
      <span>You are logged in.</span>
      <span style="float:right"><%= link_to "Logout", logout_url %></span>
    <% else %>
      <span>You are not logged in.</span>
      <span style="float:right"><%= link_to "Login", login_url %></span>
    <% end %>
  </div>
  <hr />
  <div>
    <%= yield %>
  </div>
</body>
</html>
```

## What Is Still Missing

Even with the rack-cas and rack-cas-rails gems, the aforementioned basic authentication scheme is still incomplete.  Namely, for an
authenticated session, which user does it belong to?  Or, once redirected to the login page, what username/password can be used to
authenticate?

Various Rails authentication gems makes the currently authenticated user available as an object via the ```current_user``` helper
method.  The rack-cas-rails gem does not provide this functionality.  But you can look to gems such as
[OmniAuth](https://github.com/intridea/omniauth), [Devise](https://github.com/plataformatec/devise),
[Authlogic](https://github.com/binarylogic/authlogic) and so on to provide it.

Furthermore, your CAS server installation should have integrated with one of these already.  If you are working with CASinoApp, you
can find out more about such integration at the [CASinoApp](http://rbcas.com) web site.

But, assuming your application contains a ActiveRecord model named ```User``` that has access to the same user records as your
CAS server, and each record is uniquely identifiable by a ```username``` attribute, you can add the following code to your
```ApplictionController``` to provide your application with the ```current_user``` method:

```ruby
# app/controllers/application_ronctoller.rb

require "rack_cas_rails"
class ApplicationController < ActionController::Base
  # Enforce authentication for actions of this controller
  before_action :authenticate!, except: [:index, :show]
  # ...
  def current_user
    authenciated? ? User.find_by_login(request.session["cas"]["user"]) : nil
  end
  helper_method :current_user
end
```

Now, you can change your layout to be as follows:

```erb
<!-- views/layouts/application.html.erb -->

<!DOCTYPE html>
<html>
<head>
  <title>MyGreatApplication</title>
  <%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track' => true %>
  <%= javascript_include_tag 'application', 'data-turbolinks-track' => true %>
  <%= csrf_meta_tags %>
</head>
<body>
  <div id="header">
    <% if authenticated? %>
      <span>You are logged in as <%= current_user.username %>.</span>
      <span style="float:right"><%= link_to "Logout", logout_url %></span>
    <% else %>
      <span>You are not logged in.</span>
      <span style="float:right"><%= link_to "Login", login_url %></span>
    <% end %>
  </div>
  <hr />
  <div>
    <%= yield %>
  </div>
</body>
</html>
```

At the very least, your application now knows whether a browser sessionis authenticated or not, and to whom it belongs to.  With
access to the ```User```, you can further enhance your application by adding authorization and other features to enhance its
functionality.

## Summary

With rack-cas-rails, you can integrate your Rails application with a CAS-compliant server for authentication by making these
changes:

1. Your Rails::Application subclass (in config/application.rb)
2. Your ApplicationController class (in app/controllers/application_controller.rb)
3. Your layout template (in app/views/layouts/application.html.erb)

With these changes in place, you can expect your application to exhibit the following behavior:

* When you browse to any protected view within your application using a fresh session, you'll be re-directed to the sign-in page
* After you authenticate, you'll be re-directed back to the page you browsed to
* When you click the ```Logout``` link, your session will end, and the browser will be re-directed back to the login page

## Credits

A big *thank-you* goes out the teams and contributors behind [CASinoApp](http://rbcas.com) and
[rack-cas](https://github.com/biola/rack-cas), without whom this gem will not be possible.

