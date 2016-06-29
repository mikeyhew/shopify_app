require 'test_helper'

class ShopifyApp::CarrierServicesManagerTest < ActiveSupport::TestCase

  setup do
    @carrier_services = [
      {
        name: "Example Carrier Service 1",
        active: true,
        service_discovery: true,
        callback_url: "https://example-app.com/some_url_1"
      },
      {
        name: "Example Carrier Service 2",
        active: true,
        service_discovery: true,
        callback_url: "https://example-app.com/some_url_2"
      }
    ]

    @manager = ShopifyApp::CarrierServicesManager.new(@carrier_services)
  end

  test "#create_carrier_services makes calls to create carrier_services" do
    ShopifyAPI::CarrierService.stubs(all: [])

    expect_carrier_service_creation('Example Carrier Service 1')
    expect_carrier_service_creation('Example Carrier Service 2')
    @manager.create_carrier_services
  end

  test "#create_carrier_services when creating a carrier_service fails, raises an error" do
    ShopifyAPI::CarrierService.stubs(all: [])
    carrier_service = stub(
      persisted?: false,
      errors: stub(full_messages: ["callback_url needs to be https"])
    )
    ShopifyAPI::CarrierService.stubs(create: carrier_service)

    e = assert_raise ShopifyApp::CarrierServicesManager::CreationFailed do
      @manager.create_carrier_services
    end

    assert_equal 'callback_url needs to be https', e.message
  end

  test "#recreate_carrier_services! destroys all carrier_services and recreates" do
    @manager.expects(:destroy_carrier_services)
    @manager.expects(:create_carrier_services)

    @manager.recreate_carrier_services!
  end

  test "#destroy_carrier_services makes calls to destroy carrier_services" do
    ShopifyAPI::CarrierService.stubs(:all).returns(Array.wrap(all_mock_carrier_services.first))
    ShopifyAPI::CarrierService.expects(:delete).with(all_mock_carrier_services.first.id)

    @manager.destroy_carrier_services
  end

  test "#destroy_carrier_services does not destroy carrier_services that do not have a matching name" do
    ShopifyAPI::CarrierService.stubs(:all).returns([
      stub(name: 'Some Other Carrier Service', id: 7214109)
    ])
    ShopifyAPI::CarrierService.expects(:delete).never

    @manager.destroy_carrier_services
  end

  private

  def expect_carrier_service_creation(name)
    stub_carrier_service = stub(persisted?: true)
    ShopifyAPI::CarrierService.expects(:create).with(has_entry(name: name)).returns(stub_carrier_service)
  end

  def all_mock_carrier_services
    [
      stub(
        id: 1,
        name: "Example Carrier Service 1",
      ),
      stub(
        id: 2,
        name: "Example Carrier Service 2",
      ),
    ]
  end
end
