module Spree
	class Api::V1::PagesController < Spree::Api::BaseController

		skip_before_filter :authenticate_user

		def index 
			@pages = Spree::Page.where(visible: true)
			unless @pages.blank?
				render json:{
					status: "1",
					message: "Static Page fetch Successfully",
					details: to_stringify_static_page(@pages, [])
				}
			else
				render json:{
					status: "0",
					message: "No Static Page Found"
				}
			end
		end

		private 

		def to_stringify_static_page obj, values = []
			obj.each do |page|
				Hash page_hash = Hash.new
				page_hash["title".to_sym] = page.title.to_s
				page_hash["body".to_sym] = page.body.to_s

				values.push(page_hash) 
			end

			return values
		end
	end
end