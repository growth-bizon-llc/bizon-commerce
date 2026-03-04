module Api
  module V1
    module Admin
      class SessionsController < Devise::SessionsController
        respond_to :json

        private

        def respond_with(resource, _opts = {})
          render json: {
            user: UserSerializer.new(resource).to_h,
            message: 'Logged in successfully.'
          }, status: :ok
        end

        def respond_to_on_destroy(**_opts)
          if current_user
            render json: { message: 'Logged out successfully.' }, status: :ok
          else
            render json: { message: 'Already logged out.' }, status: :unauthorized
          end
        end
      end
    end
  end
end
