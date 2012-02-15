require 'rubygems'
require 'cgi'
require 'net/http'
require 'net/https'
require 'uri'

class PaypalFx

  SERVER = "svcs.sandbox.paypal.com"
  SANDBOX = "svcs.sandbox.paypal.com"

  CLIENT_INFO = { VERSION: "60.0", SOURCE: "PayPalRubySDKV1.2.0" }

  attr_accessor :params

  # @param [Hash] with the connection params
  #    {
  #     user_id: 'user',
  #     password: 'password',
  #     signature: 'sign',
  #     app_id: 'appid',
  #     test: true
  #    }
  def initialize(params= {})
    self.params = params
  end

  # Converts an amount from origin currency to destination
  def convert(amount, origin, destination)
    request = {
        "requestEnvelope.errorLanguage" => "en_US",
        "baseAmountList.currency(0).amount" => amount,
        "baseAmountList.currency(0).code" => origin,
        "convertToCurrencyList.currencyCode(0)" => destination
    }

    commit "/AdaptivePayments/ConvertCurrency", request
  end

  # Sends the request to specified end point for paypal SANDBOX or SERVER
  #
  # @param endpoint [String] endpoint
  # @param request [Hash] request parameters
  # @return [Hash]  with the responce parameters
  def commit(endpoint, request)

    headers = {"Content-Type" => "html/text",
               "X-PAYPAL-SERVICE-VERSION" => "1.0.0",
               "X-PAYPAL-SECURITY-USERID" => self.params[:user_id],
               "X-PAYPAL-SECURITY-PASSWORD" => self.params[:password],
               "X-PAYPAL-SECURITY-SIGNATURE" => self.params[:signature],
               "X-PAYPAL-APPLICATION-ID" => self.params[:app_id],
               "X-PAYPAL-DEVICE-IPADDRESS" => self.params[:ip_address] || "",
               "X-PAYPAL-REQUEST-DATA-FORMAT" => "NV",
               "X-PAYPAL-RESPONSE-DATA-FORMAT" => "NV"}


    request_params = request.merge(CLIENT_INFO).map { |k, v| "#{k}=#{CGI.escape(v)}" }.join("&")

    http = Net::HTTP.new(params[:test] ? SANDBOX : SERVER, 443)
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.use_ssl = true

    response = http.post2 endpoint, request_params, headers

    clean_namespace CGI.parse(response.body)

  end

  protected
  def clean_namespace(hash)
    #i hate my self for this
    h = {}
    hash.each do |k, v|
      val = k.split(".").map { |k| k.tr('^A-Za-z0-9', '') }
      key = val.count == 2 ? val[1] : val[val.count-2..val.count-1].join("_")
      h[key.to_sym] = v[0]
    end
    h
  end

end