class Spree::AddressesController < Spree::StoreController
	before_filter :authenticate_spree_user!
	before_action :find_address, only: [:create, :edit, :update, :destroy]

	def index
		@address = current_spree_user.address
		if @address.blank?
			#@address = current_spree_user.orders.first.try(:bill_address).present? ? current_spree_user.orders.first.bill_address : Spree::Address.build_default
			@address = current_spree_user.orders.where("state = ? OR state = ?", "complete", "canceled").last.bill_address.present? ? current_spree_user.orders.where("state = ? OR state = ?", "complete", "canceled").last.bill_address :  Spree::Address.build_default
		end
		p @address
	end

	def edit
	end

	def create
		@addresses = Spree::Address.new(addresses_params)
		@addresses.attributes = {country_id: country = Spree::Country.find(Spree::Config[:default_country_id]).id}
		if @addresses.save
			redirect_to spree.addresses_path, notice: "Address created successfully"
		else
			render action: 'index'
		end
	end

	def update
		if @address.update_attributes(addresses_params)
			redirect_to edit_address_path(@address), notice: "Successfully updated."
		else
			render action: 'edit'
			
		end
	end

	def destroy
		@address.destroy
		redirect_to spree.new_address_path, notice: "Successfully deleted."
	end

	private

			def addresses_params
				params.require(:address).permit(:firstname, :lastname, :address1, :address2, :city, :state_name, :zipcode, :phone, :aleternative_phone, :company, :state_id, :country_id, :user_id)
			end

			def find_address
				@address = Spree::Address.where(id: params[:id]).first
			end

end