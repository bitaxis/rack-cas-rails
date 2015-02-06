# rack-cas-rails

While [rbCAS/CASinoApp](http://rbcas.com) and [biola/rack-cas](https://github.com/biola/rack-cas) are both great
and wonderful, there is gap between them.  Namely, the bits needed to enable a Rails application to use rack-cas to integrate with
CASinoApp for authentication are still missing.

This gem aims to fill in this void.

## Installation

Add the following line to a Rails application's Gemfile:

```ruby
gem "rack-cas-rails"
```

Then open up your config/application.rb file, and add the following:

## Requirements

The rack-cas-rails gem relies on the following:

  * A CAS-compliant server, such as [CASinoApp](http://rbcas.com)
  * [rack-cas](https://github.com/biola/rack-cas)
  * [rails](http://rubyonrails.org/)

## Basic Usage

The first thing you need to do is to make your Application class (file ```config/application.rb```) aware of the CAS-compliant
server you are integrating with by pointing out its base URL, like so:

```ruby
module MyGreatApplication
  class Application < Rails::Application
    # ...
    # URL of CAS server
    config.rack_cas.server_url = "https://sso.example.org/"
  end
end
```

In the simplest scenario, you'll want your entire application protected by authentication.  That is, unless a user has authenticated,
he can do nothing.  To do so, add the following ```before_action``` callback to your ApplicationController
(file ```app/controllers/application_ronctoller.rb```):

```ruby
class ApplicationController < ActionController::Base
  # authenticate all actions for all controllers
  before_action :authenticate!
  # ...
end
```

The ```authenticate!``` method will check to see if a browser session is authenticated.  If it is, controller execution will continue.
Otherwise, it will render the ```public/401.html``` file as well as return a HTTP status of 401.

So, now, create a ```pubilc/401.html``` file in your application.   You can simply copy an existing file, rename and change its
contents.

## Helper Methods

The rack-cas-rails gem also augments the ApplicationHelper module with these methods:

  * login_url
  * logout_url

When invoked, these helpers will renturn the CAS-integrated login in and log out URLs, respectively.

## What Is Still Missing

Even with the rack-cas and rack-cas-rails gems, the aforementioned basic authentication scheme is still incomplete.  Namely, for an
authenticated session, which user does it belong to?

Various Rails authentication gems makes the currently authenticated user available as an object via the ```current_user``` helper
method.  The rack-cas-rails gem does not provide this functionality.  But you can look to gems such as
[OmniAuth](https://github.com/intridea/omniauth), [Devise](https://github.com/plataformatec/devise),
[Authlogic](https://github.com/binarylogic/authlogic) and so on to provide it.

But, assuming your application has a ActiveRecord model named ```User``` where its accmpanying database table containing user records
which are uniquely identifiable by a ```username``` attribute, you can add the following code to your ApplictionController to
provide your application with the ```current_user``` method:

```ruby
class ApplicationController

  # ...
  
  def current_user
    authenciated? ? User.find_by_login(request.session["cas"]["user"]) : nil
  end

  helper_method :current_user

end
```

*Note the user records should be the same ones available to CASinoApp for authentication.*

Lastly, change your ```views/layouts/application.html.erb``` to be as follows:

```erb
<!DOCTYPE html>
<html>
<head>
  <title>MyGreatApplication</title>
  <%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track' => true %>
  <%= javascript_include_tag 'application', 'data-turbolinks-track' => true %>
  <%= csrf_meta_tags %>
</head>
<body>
  <divi id="nav-header">
    <% if authenticated? %>
      <span>Logged in as <%= current_user.username %>.</span>
      <span style="float:right"><%= link_to "Logout", logout_url %></span>
    <% else %>
      <span><%= link_to "Login", login_url %></span>
    <% end %>
  </div>
  <hr />
  <div>
    <%= yield %>
  </div>
</body>
</html>
```

## Summary

To recap, you'll have integrated your Rails application with a CAS-compliant server by making these changes to your application:

  1. Add ```config.rack_cas.server_url``` to config/application.rb
  2. Add ```before_action :authenticate!``` to ApplicationController
  3. Add ```current_user``` method to ApplictionController
  4. Add simple navigational header to make use of ```current_user``` and the ```login_url```/```logout_url``` helpers

As such, you can expect the following behavior:

  * When you browse to any view within your application using a fresh session, you'll be re-directed to the sign-in page
  * After you authenticate, you'll be re-directed back to the page you browsed to
  * When you click the Logout link, your session will end, and the browser will be re-directed back to the login page

## Credits

A big *thank-you* goes out the teams and contributors behind [CASinoApp](http://rbcas.com) and
[rack-cas](https://github.com/biola/rack-cas), without whom this gem will not be possible.

