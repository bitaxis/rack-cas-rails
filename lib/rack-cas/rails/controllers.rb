module Rack
  module CAS
    module Rails

      ##
      # All actions in controllers derived from this controller require authentication.

      class AuthenticatedController < ApplicationController

        before_action :authenticate!

        ##
        # When invoked, will force authenticate.  Most likely to be invoked as a before_action.

        def authenticate!
          authenticated? or render(:file => "public/401.html", :status => :unauthorized) # HTTP 401
        end

        ##
        # Determines whether the current request belongs to a session that is authenticated or not.
        # @return [Bool] True if current request belongs to an authenticated session, false otherwise.

        def authenticated?
          request.session["cas"] && request.session["cas"]["user"]
        end

        helper_method :authenticated?

      end
      
    end
  end
end
