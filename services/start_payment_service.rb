include PaytmHelper
module Paytm
  class StartPaymentService
    attr :order,
         :request,
         :paramList,
         :checksum_hash,
         :cart_item_id

    def initialize(attribute, request)
      @request = request
      @cart_item_id = attribute[:cart_item_id]
      find_order(attribute[:order_id])
    end

    def call
      get_param_list
    end

    private

    def find_order(order_id)
      @order = Order.find(order_id)
    end

    def get_param_list
      paramList = Hash.new
      paramList["MID"] = Rails.application.credentials[:MID]
      paramList["ORDER_ID"] = @order.order_slug
      paramList["CUST_ID"] = @order.user_id
      paramList["INDUSTRY_TYPE_ID"] = Rails.application.credentials[:INDUSTRY_TYPE_ID]
      paramList["CHANNEL_ID"] = Rails.application.credentials[:CHANNEL_ID]
      paramList["TXN_AMOUNT"] = @order.grand_total
      paramList["EMAIL"] = @order.user.email
      paramList["WEBSITE"] = Rails.application.credentials[:WEBSITE]
      paramList["CALLBACK_URL"] =
        "#{request.protocol + request.host_with_port}/confirm_payment?cart_item_id=#{cart_item_id}"

      @paramList = paramList
      @checksum_hash = generate_checksum()
    end
  end
end
