module ShopifyApp
  class AppProxyController < ApplicationController
    include ShopifyApp::AppProxyVerification

    skip_before_action :verify_authenticity_token

    before_action :verify_proxy_request
  end
end
