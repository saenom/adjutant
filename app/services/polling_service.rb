class PollingService < Interactor::Simple
  def execute
    social_networks = Settings.social_networks&.map(&:symbolize_keys)

    fail!(base: 'The list of social networks is missing!') if social_networks.blank?

    run_requests(social_networks)
  end

  private

  def run_requests(social_networks)
    hydra = Typhoeus::Hydra.hydra
    requests = social_networks.to_h { |network| [network[:name], Typhoeus::Request.new(network[:url])] }

    requests.each_value { |request| hydra.queue(request) }
    hydra.run

    requests.transform_values { |request| request.response.body.freeze }
  end
end
