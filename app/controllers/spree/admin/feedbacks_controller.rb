class Spree::Admin::FeedbacksController < Spree::Admin::ResourceController


  def index
    @feedback = Spree::Feedback.all
  end



end