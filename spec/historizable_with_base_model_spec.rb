# frozen_string_literal: true

require 'helpers/historize_helpers'

RSpec.describe 'Historio::Historizable with base_model' do
  include Helpers::HistorizeHelpers

  module Historio
    module Rspec
      module WithBaseModel
        class Hoge < ActiveRecord::Base
          include Historio::Historizable

          historize(base_model: ActiveRecord::Base)
        end
      end
    end
  end

  before :all do
    klass = Historio::Rspec::WithBaseModel::Hoge
    create_historical_model_table klass
    create_history_table klass.history_model do |table|
      table.integer :hoge_id, null: false
      table.integer :status, null: false
      table.integer :unwatched_attribute, null: false
    end
  end
  after :all do
    klass = Historio::Rspec::WithBaseModel::Hoge
    drop_table klass
    drop_table klass.history_model
  end

  let(:klass) { Historio::Rspec::WithBaseModel::Hoge }
  let(:history_klass) { klass.history_model }
  subject(:instance) { klass.create! }

  it_behaves_like 'a historized model', [{ status: 0 }, { status: 1 }]

  it { is_expected.to respond_to(:hoge_histories) }

  it { expect(history_klass.ancestors).to be_include(ActiveRecord::Base) }
end
