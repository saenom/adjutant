class PollingService < Interactor::Simple
  def execute
    begin
      social_networks = Settings.social_networks&.map(&:symbolize_keys)
    rescue Settingslogic::MissingSetting => e
      fail!(base: e.message)
    end

    fail!(base: 'The list of social networks is missing!') if social_networks.blank?

    run_requests(social_networks)
  end

  private

  def run_requests(social_networks)
    requests = {}

    hydra = Typhoeus::Hydra.hydra

    social_networks.map(&:symbolize_keys).each do |name:, url:|
      request = Typhoeus::Request.new(url)
      requests[name] = request
      hydra.queue(request)
    end

    hydra.run

    {}.tap do |result|
      requests.each do |name, request|
        result[name] = request.response.body
      end
    end
  end
end
