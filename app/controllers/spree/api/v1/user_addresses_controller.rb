module Spree
	class	Api::V1::UserAddressesController < Spree::Api::BaseController

		before_filter :find_user, only: [:show, :update, :create, :destroy]


		def create 
			unless @user.blank?
				if @user.bill_address.blank?
					@address = Spree::Address.new(addresses_params.merge({user_id: @user.id}))
					if @address.save
						@user.update_attributes(bill_address_id: @address.id)
						@user.update_attributes(ship_address_id: @address.id)
						render json:{
							status: "1",
							message: "Address saved successfully"
						}
					else
						render json:{
							status: "0",
							message: @address.errors.full_messages.join(", ")
						}
					end
				else
					if @user.bill_address.update_attributes(addresses_params) 
						render json: {
							status: "1",
							message: "Address updated successfully"
						}
					else
						render json:{
							status: "0",
							message: @user.bill_address.errors.full_messages.join(", ")
						}
					end
				end
			else
				render json:{
						status: "0",
						message: "Invalid User"
				}
			end
		end

		def show
			unless @user.blank? 
				unless @user.bill_address.blank?
						render json:{
							status: "1",
							message: "user address",
							details: to_stringify_address(@user.bill_address)
						}
				else
					render json:{
							status: "0",
							message: "User address does not exist"
						}
				end
			else
				render json:{
					status: "0",
					message: "Invalid user"
				}
			end
		end

		def update
			unless @user.blank?
				unless @user.bill_address.blank?
					if @user.bill_address.update_attributes(addresses_params)
						render json: {
							status: "1",
							message: "Address updated successfully"
						}
					else
						render json:{
						status: "0",
						message: @user.address.errors.full_messages.join(", ")
					}
					end
				else
					render json:{
							status: "0",
							message: "User address does not exist"
					}
				end
			else
				render json:{
					status: "0",
					message: "Invalid user"
				}
			end
		end

		def destroy
			unless @user.blank?
				unless @user.address.blank?
					if @user.address.destroy
						render json: {
								status: "1",
								message: "Address Deleted Sucessfully"
						}
					else
						render json:{
							status: "0",
				 			message: @user.address.errors.full_messages.join(", ")
						}
					end
				else
					render json:{
							status: "0",
							message: "User address does not exist"
					}
				end
			else
				render json:{
					status: "0",
					message: "Invalid user"
				}
			end
		end

		private

		def find_user
			api_token = params[:token] || params[:id]
			@user = Spree::ApiToken.where(token: api_token).first.try(:user) 
		end

		def addresses_params
			params.require(:address).permit(:firstname, :lastname, :address1, :address2, :city, :state_name, :zipcode, :phone, :aleternative_phone, :company, :state_id, :country_id, :user_id)
		end

		def to_stringify_address add_obj , values = []
			skip_address_attributes = ["created_at", "updated_at", "braintree_id" , "company","state_name"]
			add_hash = Hash.new
			add_obj.attributes.each do |k,v|
				 unless skip_address_attributes.include? k
				 	add_hash[k.to_sym] = v.to_s
				 end
			end
			add_hash["state_name".to_sym] = add_obj.state.name
			add_hash["country_name".to_sym] = add_obj.country.name

			values.push(add_hash)

			return values
		end


	end
end