Stripe.api_key = ENV.fetch('STRIPE_SECRET_KEY') { Rails.env.test? ? 'sk_test_dummy' : nil }
Stripe.api_version = '2024-12-18.acacia'
