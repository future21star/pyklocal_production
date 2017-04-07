module Spree
	class Api::V1::ClientTokensController < Spree::Api::BaseController

		def show
			begin
				@payment_method = Spree::PaymentMethod.find(params[:id])
				@order = Spree::Order.find_by_number(params[:order_number])
				if @payment_method.name == "Paypal"
					@client_token = @payment_method.client_token(@order)
					if @client_token.present?
						render json:{
							status: "1",
							message: "client token generate successfully",
							client_token: @client_token.to_s
						}
					else
						render json:{
							status: "0",
							error: "Something went wrong while fetching client token"
						}
					end
				else
					render json:{
						status: "0",
						message: "Wrong Payment Method ID Passed in Params"
					}
				end
			rescue Exception => e
				render json:{
					status: "0",
					error: e.message.to_s
				}
			end
		end


	end
end