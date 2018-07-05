# frozen_string_literal: true

require 'active_support/time'

module Historio
  module Historizable
    module UpdateHistory
      include Historio::Historizable::FindParams

      def update_history(options = {}, base_time = Time.zone.now)
        @base_time = base_time
        current_latest = latest_history
        return create_history(options, base_time) if current_latest.nil?
        if current_latest.watched_attributes_same?(options)
          return renew_history(current_latest, options, base_time)
        end
        create_history(options, base_time)
      end

      def create_history(options = {}, base_time = Time.zone.now)
        options = options
                  .merge(find_params)
                  .merge(
                    first_watched_at: base_time,
                    last_watched_at: base_time,
                    last_touched_at: base_time,
                    latest: true,
                  )
        self.class.history_model.transaction do
          current_latest = latest_history
          unless current_latest.nil?
            current_latest.latest = nil
            current_latest.last_touched_at = base_time
            current_latest.save!
          end

          self.class.history_model.create!(options)
        end
      end

      private

      def renew_history(history, options, base_time)
        unwatched_attributes = self.class.history_model.watched_attributes
        new_attribues = options
                        .except(unwatched_attributes)
                        .merge(
                          last_watched_at: base_time,
                          last_touched_at: base_time,
                        )
        history.assign_attributes(new_attribues)
        history.save!
      end
    end
  end
end
