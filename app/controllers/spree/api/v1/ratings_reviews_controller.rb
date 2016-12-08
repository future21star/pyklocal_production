module Spree
  class Api::V1::RatingsReviewsController < Spree::Api::BaseController

  	before_filter :find_user, only: [:create, :index]

  	def create
  		unless @user.blank?
  			@product_already_rated_by_user = Rating.where(user_id: @user.id, rateable_id: params[:rating_review][:product_id])
  			if @product_already_rated_by_user.blank?
  				@rating = Rating.new(:rateable_id => params[:rating_review][:product_id], :rating => params[:rating_review][:rating], :user_id => @user.id)
  				@comment = Comment.new(:commentable_id => params[:rating_review][:product_id], :comment => params[:rating_review][:comment], :user_id => @user.id)
  				#@comment = Comment.new(review_params.merge({user_id: @user.id}))
  				if @rating.save && @comment.save
	  				render json:{
	  					status: "1",
	  					message: "Rating and Comment Saved Successfully"
	  				}
	  			else
	  				render json:{
	  					status: "0",
	  					message: "Rating and Review could not be saved"
	  				}
	  			end
  			else
  				render json:{
  					status: "0",
  					message: "user has already rated the product"
  				}
  			end
  		else
  			render json:{
						status: "0",
						message: "Invalid User"
				}
  		end
  	end

  	def index
  		unless @user.blank?
  			@ratings = Rating.where(rateable_id: params[:product_id]).order("created_at desc")
  			#@comments = Comment.where(commentable_id: params[:product_id]).last.comment
  			unless @ratings.blank? && @comments.blank?
  				render json:{
  					status: "1",
  					message: "Rating and Review",
  					rating_details: to_stringify_rating(@ratings , [])
  					#comment_details: to_stringify_review(@comments, [])
  				}
  			else
  				render json:{
						status: "0",
						message: "Rating and Reviews does not exist for this product"
				}
  			end
  		else
  			render json:{
						status: "0",
						message: "Invalid User"
				}
  		end
  	end

  	private

		def find_user
			@user = Spree::ApiToken.where(token: params[:token]).first.try(:user)
		end

		def rating_params
			params.require(:rating).permit(:user_id, :rateable_id, :rating)
		end

		def to_stringify_rating rating_obj , values = []
			rating_obj.each do |rating|
				rating_hash = Hash.new
				rating_hash["id".to_sym] = rating.id.to_s
				rating_hash["product_id".to_sym] = rating.rateable_id.to_s
				rating_hash["date".to_sym] = rating.created_at.to_s
				rating_hash["rating".to_sym] = rating.rating.to_s
				rating_hash["first_name".to_sym] = rating.user.first_name.to_s
				rating_hash["Last_name".to_sym] = rating.user.last_name.to_s
				rating_hash["comment".to_sym] = Comment.find(rating.id).comment.to_s
				values.push(rating_hash)
			end

			return values
		end

		def to_stringify_review review_obj , values = []
			review_hash = Hash.new
			#review_hash["id".to_sym] = review_obj.id.to_s
			#review_hash["product_id".to_sym] = review_obj.commentable_id.to_s
			review_hash["comment".to_sym] = review_obj.to_s

			values.push(review_hash)

			return values
		end

		def rating_review_params
			params.require(:rating_review).permit(:user_id, :product_id, :comment, :rating)
		end

  end
end