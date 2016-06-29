module ShopifyApp
  module AppProxyVerification
    extend ActiveSupport::Concern

    included do
      skip_before_action :verify_authenticity_token
      before_action :verify_proxy_request
    end

    def verify_proxy_request
      return head :unauthorized unless query_string_valid?(request.query_string)
    end

    def query_string_valid?(query_string)
      query_hash = Rack::Utils.parse_query(query_string)

      signature = query_hash.delete('signature')
      return false if signature.nil?

      sorted_params = query_hash.collect{|k,v| "#{k}=#{Array(v).join(',')}"}.sort.join

      ActiveSupport::SecurityUtils.secure_compare(
        calculated_signature(sorted_params),
        signature
      )
    end

    private

    def calculated_signature(sorted_query_params)
      OpenSSL::HMAC.hexdigest(
        OpenSSL::Digest.new('sha256'),
        ShopifyApp.configuration.secret,
        sorted_query_params
      )
    end
  end
end
