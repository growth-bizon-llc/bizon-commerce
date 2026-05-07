Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    if ENV['CORS_ORIGINS'].present?
      origins ENV['CORS_ORIGINS'].split(',').map(&:strip)
    elsif Rails.env.production?
      origins 'https://example.com'
    else
      origins '*'
    end

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ['Authorization', 'X-Cart-Token']
  end
end
