require 'test_helper'

class AppProxyControllerTest < ActionController::TestCase

  class MyAppProxyController < ShopifyApp::AppProxyController
    def basic
      render text: 'verified'
    end
  end

  setup do
    Rails.application.routes.draw { match ':controller(/:action)', via: [:get, :post] }
    ShopifyApp.configure do |config|
      config.secret = "secret"
    end
  end

  teardown do
    Rails.application.reload_routes!
  end

  tests MyAppProxyController

  test 'should_fail_verification' do
    get(:basic, shop: 'some-random-store.myshopify.com', path_prefix: '/apps/my-app', timestamp: '1466106083', signature: 'wrong233558b1c50102a6f33c0b63ad1e1072a2fc126cb58d4500f75223cefcd')
    assert_response(:unauthorized)
  end

  test 'should_pass_verification' do
    get(:basic, shop: 'some-random-store.myshopify.com', path_prefix: '/apps/my-app', timestamp: '1466106083', signature: 'f5cd7233558b1c50102a6f33c0b63ad1e1072a2fc126cb58d4500f75223cefcd')
    assert_response(:ok)
  end

end
