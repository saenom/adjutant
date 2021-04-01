class HomeController < ApplicationController
  def show
    PollingService.run!
      .on_success { |body| render json: body, status: :ok }
      .on_failure { |errors| render json: { error: errors.values.join('. ') }, status: :internal_server_error }
  end
end
