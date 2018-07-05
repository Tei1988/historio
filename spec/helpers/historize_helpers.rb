# frozen_string_literal: true

module Helpers
  module HistorizeHelpers
    def create_historical_model_table(klass)
      migration = migration(klass)
      migration.create_table klass.table_name.to_sym do |table|
        yield table if block_given?
      end
    end

    def create_history_table(klass)
      migration = migration(klass)
      migration.create_table klass.table_name.to_sym do |table|
        yield table if block_given?
        table.datetime :first_watched_at, null: false
        table.datetime :last_watched_at, null: false
        table.datetime :last_touched_at, null: false
        table.boolean :latest, null: true
      end
    end

    def drop_table(klass)
      migration = migration(klass)
      migration.drop_table klass.table_name.to_sym
    end

    private

    def migration(klass)
      ActiveRecord::Migration.new.tap do |migration|
        migration.verbose = false
        migration.instance_variable_set('@connection', klass.connection)
      end
    end
  end
end
