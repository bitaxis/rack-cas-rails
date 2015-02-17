# rack-cas-rails

[rbCAS/CASinoApp](https://github.com/rbcas/casinoapp) is a great single sign-on authentication server, and
[biola/rack-cas](https://github.com/biola/rack-cas) provides a simple means to integrate with it.  However, these two things
coupled with your Rails application do not a **single sign-on enabled application** make.  That is, there are still some bits
missing.

This gem aims to provide some of the bits to close the gap.

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

  * A working installation of [CASinoApp](http://rbcas.com), although theoretically it should work with any CAS-compliant server
  * [rack-cas](https://github.com/biola/rack-cas)
  * [rails](http://rubyonrails.org/)

Having access to a working CAS-compliant server is a pre-requisite.  [CASinoApp](http://rbcas.com) is a simple one to set up and
use, especially if you go with the ***directly on your server*** option.  Whiichever CAS server you go with, you'll need to
know the password of at least one login for testing purposes.

### Disclaimer

I don't have access to any other CAS servers except an instance of CASinoApp I have installed and configured.  So I have
only ever developed and tested against it.  If you are able to try it against others, please let me know how well it works.

## Basic Usage

Now that you have access to a functioning CAS-compliant server, the next thing you need to do is to make your ```Rails::Application```
subclass aware of the server you are integrating with by pointing out its base URL, as shown here.

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

require "rack-cas-rails"
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate!
end
```

The ```authenticate!``` helper will check to see if a browser session is authenticated.  If it is, controller execution will continue.
Otherwise, it will render the ```public/401.html``` file if one exists, as well as return a HTTP status of 401.

At this point, if you fire up your application and browse to access any view of any controller subclassed from
```ApplicationController```, the browser will get re-directed to the CAS server's log-in page.

## Helper Methods

The rack-cas-rails gem also adds some helper methods:

* authenticate!
* authenticated?
* login_url
* logout_url

You have already seen ```authenticate!``` at work.  The ```authenticated?``` helper allows your application to determine whether
a browser is authenticated or not and take appropriate action.  When invoked, the latter two helpers will return the
CAS-integrated login and log out URLs, respectively.  They, in turn, enable you to implement *partial authentication*.

## Partial Authentication

In this case, only certain portions of your application requires authentication.  For example, perhaps actions that are
*read-only* need not be protected by authentication.  To do this, change your ```ApplicationController``` as follows:

```ruby
# app/controllers/application_ronctoller.rb

require "rack-cas-rails"
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate!, except: [:index, :show]
end
```

Restart your application and browse to a *read-only* endpoint like ```/index``` or ```/show```, and you will not be re-directed
to the CAS log-in page.  But if you browse to other endpoints like ```/new```, you will be re-directed and prompted to
authenticate.

Go back and look at the read-only endpoint.  It would be nice to have some indication telling a user whether he's logged in or not.
So, open up your application layout and add a ```<div>``` container that will behave differently bepending on the authentication
status of a browser session.

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

Refresh your browser.  This time you'll see that you're not logged in, but you are also given a login URL.  Click on it, and you'll
be prompted to log-in once again.

## What Is Still Missing

However, the basic authentication scheme we have cooked up is still incomplete.  Namely:

* What credentails should a user use to login, and how does your application verify it?
* Once a user has authenticated, how does your application know about that user?

The first point is that your application doesn't have to worry about it, since that is the whole point of CAS (and single sign-on).
Once your CAS server is set up, any application you write and integrate with it won't have to worry about it.  Your CAS
server will take care of it for you.

The second point, however,requires some explanation and experimentation...

Once a user has authenticated, the [rack-cas](https://github.com/biola/rack-cas) gem will insert some information about
that user into your application's session for it to retrieve.  Your application should then take this information, usually
in the form of a username, and look up information about that user.  Based on the information available, your application can
then implement additional features such as authorziation (not covered here).

Ideally, your application should use the same data repository as your CAS server to look up user information.  That repository can
be a SQL database table, some LDAP server, or any number of things.  But for now, we can fake it.

Go ahead and create a scaffold around a Person model (or any other name you'd like to use), like so:

```
$ rails generate scaffold person name:string age:integer
$ rake db:migrate
```

Populate the ```people``` table with at least one row where the ```name``` column has the same value as one of the users your CAS
server knows about and you know the password of.  For example, let's use "jsmith":

```
$ rails console
Loading development environment (Rails 4.2.0)
2.2.0 :001 > person = Person.new(name: "jsmith", age: 123)
 => #<Person id: nil, name: "jsmith", age: 123, created_at: nil, updated_at: nil> 
2.2.0 :002 > person.save!
   (0.2ms)  begin transaction
  SQL (33.5ms)  INSERT INTO "people" ("name", "age", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["name", "jsmith"],
  ["age", 123], ["created_at", "2015-02-16 02:27:18.121111"], ["updated_at", "2015-02-16 02:27:18.121111"]]
   (1.5ms)  commit transaction
 => true 
2.2.0 :003 > quit
```

Now, let's add a helper named ```current_user``` (or any other name you like) to your application:

```ruby
# app/controllers/application_ronctoller.rb

require "rack-cas-rails"
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate!, except: [:index, :show]
  def current_user
    authenticated? ? Person.find_by_name(request.session["cas"]["user"]) : nil
  end
  helper_method :current_user
end
```

Next, change your layout to be as follows:

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
      <span>You are logged in as <%= current_user.name %>.</span>
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

Restart your application again, and visit an ```/index``` endpoint.  Click the __Login__ link, and authenticate using "jsmith"
(or whichever user you chose) and the correct password.  Once authenticated, you'll be re-directed back to the original page.
This time, you are shown whom you are logged in as.  Now visit a ```/new``` endpoint, and you won't be prompted to authenticate
again, until you click the __Logout__ link or restart your browser.

## Summary

With rack-cas-rails, you can integrate your Rails application with CASinoApp or another CAS-compliant server for
authentication by making these changes in it:

1. Your Rails::Application subclass (in config/application.rb)
2. Your ApplicationController class (in app/controllers/application_controller.rb)
3. Your layout template (in app/views/layouts/application.html.erb)
4. Add a model (or some other means) by which you can retrieve information about the currently logged in user

With these changes in place, you can expect your application to exhibit the following behavior:

* When you browse to any protected endpoint within your application using a fresh session, you'll be re-directed to the sign-in page
* After you authenticate, you'll be re-directed back to the page you browsed to, after which you'll have access to all endpoints
* When you click the __Logout__ link or restart your browser, your session will end; and should you now attempt to access
  a protected enpoint, you'll be prompted to log in once again

## Credits

A big *thank-you* goes out the teams and contributors behind [CASinoApp](http://rbcas.com) and
[rack-cas](https://github.com/biola/rack-cas), without whom this gem will not be possible.

