# Module for oauth access
require 'oauth/consumer'

module OauthMod
class Base
  attr_reader :names, :updates
  attr_reader :access_token
  attr_reader :consumer
  attr_accessor :proxy
  
  def initialize(consumer_key, consumer_secret, options)
    @consumer = OAuth::Consumer.new(consumer_key, consumer_secret,
      options)
    # Enable debugging
    # @consumer.http.set_debug_output($stderr)
  end
  
  # Return the response from site.
  def post_to(site, content_hash)
  @access_token.post(site, content_hash, 
    {'Accept' => 'application/xml'})
  end
  
  # @updates must be set up before calling this
  def make_html
    out = "<html>\n"
    @updates.each do |u|
      out << u[:id] + ": "
      out << u[:from] + " "
      out << u[:content] + "--- "
      out << u[:time] + "<br><br>\n"      
    end
    out << "</html>\n"
  end
end

# Include Access module in a sub-class of class containing OauthMod::Base
module Access
  def initialize(credentials, access_token)
    super(credentials['key'], credentials['secret'], credentials['options'])
    @access_token = OAuth::AccessToken.new(@consumer, access_token['token'], access_token['secret'])
  end
end
  
# Include Access module in a sub-class of class containing OauthMod::Base
module Request
  attr_reader :authorize_url
  attr_reader :request_token
  
  # After Access.new, you need to complete verify for further access
  # Access.new returns the URL for the user to go to
  # Pass in old request token/secret if recreating a request token
  def initialize(credentials, callback_url, req_token=nil)
    super(credentials['key'], credentials['secret'], credentials['options'])
    if (req_token)
      @request_token = OAuth::RequestToken.new(@consumer, req_token['token'], req_token['secret'])
    else
      @request_token = @consumer.get_request_token(:oauth_callback => callback_url)
    end
    @authorize_url = @request_token.authorize_url(:oauth_callback => callback_url)
  end
  
  # Pass in the verifier code that was obtained by the user
  # After this, save credentials (@access_token.token, @access_token.secret) for next time
  def verify(verifier)
    @access_token = @request_token.get_access_token(:oauth_verifier => verifier)
  end
end    
  
end
