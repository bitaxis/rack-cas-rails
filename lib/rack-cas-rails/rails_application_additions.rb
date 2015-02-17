##
# Augments the Rails::Application class.

class Rails::Application < Rails::Engine

  ##
  # Gives the Rails::Application class a read-only class attribute to point to the CAS server URL.  The URL in turn is then
  # settable using @cas_server_url at the class level.

  class << self
    attr_reader :cas_server_url
  end

  ##
  # Gets the CAS server root URL.  Provides a convenience method at the instance level to fetch it.
  # @return [String] Cas server's root URL.

  def cas_server_url
    self.class.cas_server_url
  end

end
