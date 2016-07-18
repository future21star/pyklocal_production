Spree::BaseHelper.module_eval do 
	def available_countries
    checkout_zone = Spree::Zone.find_by(name: Spree::Config[:checkout_zone])

    if checkout_zone && checkout_zone.kind == 'country'
      countries = Spree::Country.where(id: 232) rescue Spree::Country.find(Spree::Config[:default_country_id])
    else
      countries = Spree::Country.where(id: 232) rescue Spree::Country.find(Spree::Config[:default_country_id])
    end

    countries.collect do |country|
      country.name = Spree.t(country.iso, scope: 'country_names', default: country.name)
      country
    end.sort_by { |c| c.name.parameterize }
  end

  def flash_message
    message = ""
    [:notice, :alert, :success, :error, :warning, :information, :confirm].each do |type| 
      if(!flash[type].blank?)
        return {
          text: flash[type],
          type: ((type == :notice) ? 'information' : type)
        }
      end
    end
    return nil;
  end

end
