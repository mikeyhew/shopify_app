module ShopifyApp
  class CarrierServicesManagerJob < ActiveJob::Base

    queue_as do
      ShopifyApp.configuration.carrier_services_manager_queue_name
    end

    def perform(shop_domain:, shop_token:, carrier_services:)
      ShopifyAPI::Session.temp(shop_domain, shop_token) do
        manager = CarrierServicesManager.new(carrier_services)
        manager.create_carrier_services
      end
    end
  end
end
