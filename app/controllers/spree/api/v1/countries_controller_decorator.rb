module Spree
  Api::V1::CountriesController.class_eval do

  	def index
  		@countries = Spree::Country.all
  		if @countries 
  			render json:{
  				status: "1",
  				message: "country",
  				details: to_stringify_country(@countries , [])
  			}
  		else
  			render json:{
  				status: "0",
  				message: "something went wrong"
  			}
  		end
  	end

  		def states
  			@states = Spree::State.where(country_id: params[:id])
  			if @states 
  			render json:{
  				status: "1",
  				message: "state",
  				details: to_stringify_state(@states , [])
  			}
    		else
    			render json:{
    				status: "0",
    				message: "something went wrong"
    			}
    		end
  		end

      private
      def to_stringify_country country_obj , values = []
        
        country_obj.each do |country|
          country_hash = Hash.new
          country_hash["id".to_sym] = country.id.to_s
          country_hash["code".to_sym] = country.iso3.to_s
          country_hash["name".to_sym] = country.name.to_s

          values.push(country_hash)
        end
         
        

        return values
      end

      def to_stringify_state state_obj ,values = []
        
        state_obj.each do |state|
          state_hash = Hash.new
          state_hash["id".to_sym] = state.id.to_s
          state_hash["code".to_sym] = state.abbr.to_s
          state_hash["name".to_sym] = state.name.to_s

          values.push(state_hash)
        end
         
        

        return values
      end
  end
end