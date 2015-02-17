module RackCASRails
end

##
# Augment Rails' ApplicationController class with authentication related methods.

class ApplicationController < ActionController::Base

  ##
  # When invoked, will force authenticate.  Most likely to be invoked as a before_action.

  def authenticate!
    return if authenticated?
    if File.exists?("public/401.html")
      render(:file => "public/401.html", :status => :unauthorized)
    else
      render(:plain => "Unauthorized!", :status => :unauthorized)
    end
  end

  ##
  # Determines whether the current request belongs to a session that is authenticated or not.
  # @return [Bool] True if current request belongs to an authenticated session, false otherwise.

  def authenticated?
    request.session["cas"] && request.session["cas"]["user"]
  end

  ##
  # Renders the CAS login URL with re-direct back to some URL.
  # @param service_url [String] Optional url to redirect to after authentication.
  # @return [String] The CAS login URL.

  def login_url(service_url=request.url)
    url = URI(Rails.application.cas_server_url)
    url.path = "/login"
    url.query = "service=#{service_url || request.url}"
    url.to_s
  end

  ##
  # Renders the CAS logout URL with re-direct back to some URL (e.g. the root URL).  The logout path is "/logout",
  # which is actually undocumented.  I had to find out by looking into the source code of the rack-cas gem.
  # @param service_url [String] Optional url to redirect to after authentication.
  # @return [String] The CAS logout URL.

  def logout_url(service_url=request.url)
    url = URI(request.url)
    url.path = "/logout"
    url.query = "service=#{service_url || request.url}"
    url.to_s
  end

  helper_method :authenticate!
  helper_method :authenticated?
  helper_method :login_url
  helper_method :logout_url

end

##
# All actions in controllers derived from this controller require authentication.

class RackCASRails::AuthenticatedController < ApplicationController
  before_action :authenticate!
end
