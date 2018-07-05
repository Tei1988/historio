# frozen_string_literal: true

require 'helpers/historize_helpers'

RSpec.describe 'Historio::Historizable with history_model' do
  include Helpers::HistorizeHelpers

  module Historio
    module Rspec
      module WithHistoryModel
        class Fuga < ActiveRecord::Base
          include Historio::HistoryModel

          watches :status_a
          watches :status_b
        end

        class Hoge < ActiveRecord::Base
          include Historio::Historizable

          historize(history_model: Fuga)
        end
      end
    end
  end

  before :all do
    klass = Historio::Rspec::WithHistoryModel::Hoge
    create_historical_model_table klass
    create_history_table klass.history_model do |table|
      table.integer :hoge_id, null: false
      table.integer :status_a, null: false
      table.integer :status_b, null: false
      table.integer :unwatched_attribute, null: false
    end
  end
  after :all do
    klass = Historio::Rspec::WithHistoryModel::Hoge
    drop_table klass
    drop_table klass.history_model
  end

  let(:klass) { Historio::Rspec::WithHistoryModel::Hoge }
  let(:history_klass) { klass.history_model }
  subject(:instance) { klass.create! }

  it_behaves_like 'a historized model', [
    { status_a: 0, status_b: 1 }, { status_a: 1, status_b: 0 }
  ]
  it_behaves_like 'a historized model', [
    { status_a: 0, status_b: 1 }, { status_a: 0, status_b: 0 }
  ]
  it { is_expected.to respond_to(:fugas) }
end
