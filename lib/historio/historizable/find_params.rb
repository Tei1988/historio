# frozen_string_literal: true

module Historio
  module Historizable
    module FindParams
      private

      def find_params
        @find_params ||= {
          historical_model_id => id, latest: true
        }.freeze
      end

      def historical_model_id
        "#{self.class.historical_model.model_name.element}_id".to_sym
      end
    end
  end
end
