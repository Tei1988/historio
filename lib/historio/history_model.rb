# frozen_string_literal: true

require 'validates_timeliness'

module Historio
  module HistoryModel
    class << self
      def included(klass)
        class << klass
          def watched_attributes
            @watched_attributes ||= []
          end

          def watches(attribute)
            return if watched_attributes.include?(attribute)
            watched_attributes.push(attribute)
          end

          def comparation_target?(key, value)
            watched_attributes.include?(key) && value.present?
          end
        end

        modify(klass)
      end

      private

      def modify(klass)
        klass.validates :first_watched_at,
                        presence: true, timeliness: { type: :datetime }
        klass.validates :last_watched_at,
                        presence: true, timeliness: { type: :datetime }
        klass.validates :last_touched_at,
                        presence: true, timeliness: { type: :datetime }
        klass.validates :latest, inclusion: { in: [true, nil] }
      end
    end

    def watched_attributes_same?(params = {})
      if self.class.watched_attributes.empty?
        params[:status] == send(:status)
      else
        comparation_target = self.class.method(:comparation_target?)
        params.select(&comparation_target) ==
          attributes.symbolize_keys.select(&comparation_target)
      end
    end
  end
end
