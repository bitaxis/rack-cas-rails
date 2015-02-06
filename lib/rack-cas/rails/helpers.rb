module RackCAS
  module Rails
  end
end

##
# Augment the ApplicationHelper module with these methods.

module ApplicationHelper

  ##
  # Renders the CAS login URL with re-direct back to some URL.
  # @param service_url [String] Optional url to redirect to after authentication.
  # @return [String] The CAS login URL.

  def login_url(service_url=request.url)
    url = URI(Rails.application.config.rack_cas.server_url)
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

end
