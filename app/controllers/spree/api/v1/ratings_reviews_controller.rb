module Spree
  class Api::V1::RatingsReviewsController < Spree::Api::BaseController

  	before_filter :find_user, only: [:create, :index]

  	def create
  		unless @user.blank?
  			@product_already_rated_by_user = Rating.where(user_id: @user.id, rateable_id: params[:rating][:rateable_id])
  			if @product_already_rated_by_user.blank?
  				@rating = Rating.new(rating_params.merge({user_id: @user.id}))
  				@comment = Comment.new(review_params.merge({user_id: @user.id}))
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
  			@ratings = Rating.where(rateable_id: params[:product_id]).last
  			@comments = Comment.where(commentable_id: params[:product_id]).last
  			unless @ratings.blank? && @comments.blank?
  				render json:{
  					status: "1",
  					message: "Rating and Review",
  					rating_details: to_stringify_rating(@ratings , []) ,
  					comment_details: to_stringify_review(@comments, [])
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
			rating_hash = Hash.new
			rating_hash["id".to_sym] = rating_obj.id.to_s
			rating_hash["product_id".to_sym] = rating_obj.rateable_id.to_s
			rating_hash["rating".to_sym] = rating_obj.rating.to_s
			rating_hash["first_name".to_sym] = rating_obj.user.first_name.to_s
			rating_hash["Last_name".to_sym] = rating_obj.user.last_name.to_s
			values.push(rating_hash)

			return values
		end

		def to_stringify_review review_obj , values = []
			review_hash = Hash.new
			review_hash["id".to_sym] = review_obj.id.to_s
			review_hash["product_id".to_sym] = review_obj.commentable_id.to_s
			review_hash["comment".to_sym] = review_obj.comment.to_s

			values.push(review_hash)

			return values
		end

		def review_params
			params.require(:review).permit(:user_id, :commentable_id, :comment)
		end

  end
end