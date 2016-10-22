module Spree
	class	Api::V1::UserAddressesController < Spree::Api::BaseController

		before_filter :find_user, only: [:show, :update, :create, :destroy]


		def create 
			unless @user.blank?
				@address = Spree::Address.new(addresses_params.merge({user_id: @user.id}))
				if @address.save
					render json:{
						status: "1",
						message: "Address saved successfully"
					}
				else
					render json:{
						status: "0",
						message: "Something went wrong"
					}
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
				unless @user.address.blank?
					if @user.address.id == params[:id].to_i
						render json:{
							status: "1",
							message: "user address",
							details: to_stringify_address(@user.address)
						}
					else
						render json:{
							status: "0",
							message: "Invalid Address id"
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

		def update
			unless @user.blank?
				unless @user.address.blank?
					if @user.address.id == params[:id].to_i
						if @user.address.update_attributes(addresses_params)
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
							message: "Invalid Address id"
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
					if @user.address.id == params[:id].to_i
						if @user.address.destroy
							render json: {
								status: "1",
							 	message: "Address Deleted Sucessfully"
							}
						else
							render json:{
							status: "0",
							message: "Something went wrong"
						}
						end
					else
						render json:{
							status: "0",
							message: "Invalid Address id"
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
			@user = Spree::ApiToken.where(token: params[:token]).first.try(:user)
		end

		def addresses_params
			params.require(:address).permit(:firstname, :lastname, :address1, :address2, :city, :state_name, :zipcode, :phone, :aleternative_phone, :company, :state_id, :country_id, :user_id)
		end

		def to_stringify_address add_obj , values = []
			skip_address_attributes = ["created_at", "updated_at", "braintree_id" , "company"]
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