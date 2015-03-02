module RackCASRails
  module ActionControllerBaseAdditions

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
    # @note
    #   This helper depends on your application having a root route, so that the *root_url* helper is defined.  Otherwise,
    #   it degrades to current request URL's scheme + host + port + "/logout", which may not be what you want, especially in
    #   sub-URI hosting situations.

    def logout_url(service_url=request.url)
      if self.respond_to?(:root_url)
        url = URI(root_url)
        url.path += "logout"
      else
        url = URI(request.url)
        url.path = "/logout"
      end
      url.query = "service=#{service_url || request.url}"
      url.to_s
    end

    def self.included(base)
      # Expose newly added instance methods as helpers
      base.helper_method :authenticate!
      base.helper_method :authenticated?
      base.helper_method :login_url
      base.helper_method :logout_url
    end

  end
end

# Add instance mthods to the ActionController::Base class
ActionController::Base.class_eval do
  include RackCASRails::ActionControllerBaseAdditions
end

