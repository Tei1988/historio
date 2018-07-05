# frozen_string_literal: true

module Historio
  module Historizable
    module Historize
      attr_writer :base_model
      attr_accessor :historical_model
      attr_writer :history_model

      def historize(options = {})
        @base_model = options[:base_model]
        @history_model = options[:history_model]

        @historical_model.has_many history_has_many_definition
        history_model.belongs_to historical_model_belongs_to_definition
        history_model.include Historio::HistoryModel
      end

      def history_model
        @history_model ||= create_history_model
      end

      private

      def history_has_many_definition
        history_model.model_name.element.pluralize.to_sym
      end

      def historical_model_belongs_to_definition
        @historical_model.model_name.element.to_sym
      end

      def create_history_model
        if historical_model_module.const_defined?(history_model_name)
          return historical_model_module.const_get(history_model_name)
        end
        history_model_instance.tap do |klass|
          historical_model_module.const_set(history_model_name, klass)
        end
      end

      def base_model
        @base_model ||= ::ActiveRecord::Base
      end

      def history_model_instance
        Class.new(base_model)
      end

      def historical_model_module
        historical_model_module_name =
          @historical_model.model_name.name.deconstantize
        return Object if historical_model_module_name.empty?
        historical_model_module_name.constantize
      end

      def history_model_name
        @history_model_name ||=
          "#{@historical_model.model_name.name.demodulize}History"
      end
    end
  end
end
