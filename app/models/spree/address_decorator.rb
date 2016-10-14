module Spree
	Address.class_eval do
		
		def get_address
			address_hash = Hash.new
			country_hash = Hash.new
      state_hash = Hash.new
			attributes.each do |k, v|
				if k.eql?"state_id"
          state.attributes.each do |k1,v1|
            if k1.eql?"country_id"
              state.country.attributes.each do |k2,v2|
                country_hash[k2.to_sym] = v2.to_s
              end
              address_hash["country".to_sym] = country_hash
            end
          	state_hash[k1.to_sym] = v1.to_s
        	end
        	address_hash["state".to_sym] = state_hash
        end
        address_hash[k.to_sym] = v.to_s
      end		
      return address_hash	
		end

	end
end