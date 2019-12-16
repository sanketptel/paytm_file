class PaytmController < ApplicationController
  include PaytmHelper
  before_action :authenticate_user!
  include CurrentCart
  before_action :set_cart

  def start_payment
    start_payment = Paytm::StartPaymentService.new(params, request)
    start_payment.call
    @checksum_hash = start_payment.checksum_hash
    @paramList = start_payment.paramList
  end

  def verify_payment
    paytm_verify = Paytm::VerifyPaymentService.new(params, @cart)
    paytm_verify.call
    @paytmparams = paytm_verify.paytmparams
    redirect_to orders_path
  end
end
