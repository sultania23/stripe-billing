class SubscriptionsController < ApplicationController

	def show
	end
	def new
	end
	def create
		customer = if current_user.stripe_id?
		             Stripe::Customer.retrieve(current_user.stripe_id)
		           else
		             Stripe::Customer.create(email: current_user.email)
	               end


	    subscription = customer.subscriptions.create(
	    source: params[:stripeToken],
	    plan: "monthly"
	    )         

	    current_user.update(
	    	stripe_id: customer.id,
	    	stripe_subscription_id: subscription.id,
	    	card_last4: params[:card_last4],
	    	card_exp_month: params[:card_exp_month],
	    	card_exp_year: params[:card_exp_year],
	    	card_type: params[:card_type]
	    	)   
		
		redirect_to root_path

	end

	def destroy
		customer = Stripe::Customer.retrieve(current_user.stripe_id)
		customer.subscriptions.retrieve(current_user.stripe_subscription_id).delete
		current_user.update(stripe_subscription_id: nil) 

		redirect_to root_path, notice: "subscription has been cancelled."
	end

end