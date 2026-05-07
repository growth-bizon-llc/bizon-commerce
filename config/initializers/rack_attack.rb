class Rack::Attack
  # Rate limit auth endpoints: 5 requests per 20 seconds per IP
  throttle("auth/ip", limit: 5, period: 20.seconds) do |req|
    if req.post? && [
      "/api/v1/admin/auth/sign_in",
      "/api/v1/storefront/session",
      "/api/v1/storefront/customers"
    ].include?(req.path)
      req.ip
    end
  end

  self.throttled_responder = lambda do |_env|
    [429, { "Content-Type" => "application/json" }, [{ error: "Rate limit exceeded. Try again later." }.to_json]]
  end
end
