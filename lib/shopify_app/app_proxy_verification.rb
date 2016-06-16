module ShopifyApp
  module AppProxyVerification
    extend ActiveSupport::Concern

    # Usage:
    #   include ShopifyApp::AppProxyVerification
    #   before_action :verify_proxy_request
    def verify_proxy_request
      return head :unauthorized unless query_string_valid?(request.query_string)
    end

    def query_string_valid?(query_string)
      query_hash = Rack::Utils.parse_query(query_string)

      signature = query_hash.delete('signature')
      return false if signature.nil?

      sorted_params = query_hash.collect{|k,v| "#{k}=#{Array(v).join(',')}"}.sort.join

      calculated_signature = OpenSSL::HMAC.hexdigest(
        OpenSSL::Digest.new('sha256'),
        ShopifyApp.configuration.secret,
        sorted_params
      )

      ActiveSupport::SecurityUtils.secure_compare(
        calculated_signature,
        signature
      )
    end
  end
end
