# frozen_string_literal: true

module Historio
  module Historizable
    module LatestHistory
      include Historio::Historizable::FindParams

      def latest_history
        self.class.history_model.find_by(find_params)
      end
    end
  end
end
