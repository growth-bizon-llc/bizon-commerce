module AuthHelpers
  def auth_headers_for(user)
    token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
    { 'Authorization' => "Bearer #{token}" }
  end

  def storefront_headers_for(store)
    { 'X-Store-Domain' => store.custom_domain || store.subdomain }
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
