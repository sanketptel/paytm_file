include PaytmHelper
module Paytm
  class VerifyPaymentService
    attr_reader :order_id,
                :cart,
                :keys,
                :paytmparams,
                :cart_item_id

    def initialize(attribute, cart)
      @order_id = attribute[:ORDERID]
      @cart = cart
      @cart_item_id = attribute[:cart_item_id]
      @attribute = attribute
      @keys = attribute.keys
    end

    def call
      find_order
      find_cart_item
      destroy_cart_items
      paytm_params
    end

    private

    def find_order
      @order = Order.find_by(order_slug: order_id)
      @order.update(order_conformation: Order.order_conformations.keys.second) if @attribute[:STATUS] == 'TXN_SUCCESS'
    end

    def find_cart_item
      @cart_item = CartItem.find_by(id: cart_item_id)
    end

    def destroy_cart_items
      if @attribute[:STATUS] == 'TXN_SUCCESS'
        cart_item_id.present? ? @cart_item.destroy : @cart.cart_items.destroy_all
      end
    end

    def paytm_params
      paytmparams = Hash.new
      @keys.each do |k|
        paytmparams[k] = @attribute[k]
      end
      @checksum_hash = paytmparams["CHECKSUMHASH"]
      paytmparams.delete("CHECKSUMHASH")
      paytmparams.delete("controller")
      paytmparams.delete("action")
      @paytmparams = paytmparams
      is_valid_checksum = verify_checksum()

      if is_valid_checksum == true
        if paytmparams["STATUS"] == "TXN_SUCCESS"
          respond_to do |format|
            format.html
          end
        else
          respond_to do |format|
            format.html
          end
        end
      end
      send_order_mail
    end

    def send_order_mail
      OrderMailer.order_email(@order).deliver_now if @attribute[:STATUS] == 'TXN_SUCCESS'
    end
  end
end
