# config/initializers/stripe.rb

Stripe.api_key = ENV['STRIPE_SECRET_KEY']
STRIPE_PUBLISHABLE_KEY = ENV['STRIPE_PUBLISHABLE_KEY']
STRIPE_WEBHOOK_SECRET = ENV['STRIPE_WEBHOOK_SECRET']
STRIPE_PRICE_ID = ENV['STRIPE_PRICE_ID']