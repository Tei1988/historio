# frozen_string_literal: true

module Historio
  module Historizable
    autoload :Historize, 'historio/historizable/historize'
    autoload :FindParams, 'historio/historizable/find_params'
    autoload :LatestHistory, 'historio/historizable/latest_history'
    autoload :UpdateHistory, 'historio/historizable/update_history'

    def self.included(klass)
      class << klass
        include Historio::Historizable::Historize
      end
      klass.historical_model = klass
    end

    include Historio::Historizable::LatestHistory
    include Historio::Historizable::UpdateHistory
  end
end
