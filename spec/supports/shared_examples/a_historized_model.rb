# frozen_string_literal: true

RSpec.shared_examples 'a historized model' do |(data_a, data_b)|
  it { is_expected.to respond_to(:latest_history) }
  it { is_expected.to respond_to(:update_history) }

  describe '.latest_history' do
    context 'no histories are recorded' do
      it 'returns nil' do
        expect(instance.latest_history).to be_nil
      end
    end
    context 'there is two history records' do
      let(:current_time) { Time.now }
      let!(:histories) do
        [true, nil].map do |latest|
          history_klass.create!(data_a.merge(hoge: instance,
                                             unwatched_attribute: 0,
                                             first_watched_at: current_time,
                                             last_watched_at: current_time,
                                             last_touched_at: current_time,
                                             latest: latest))
        end
      end
      it 'returns latest marked one' do
        expect(instance.latest_history)
          .to have_attributes(data_a.merge(hoge_id: instance.id, latest: true))
      end
    end
  end

  describe '.update_history' do
    let(:issued_at) { Time.at(Time.now.to_i, 0) }
    let(:executed_at) { issued_at + 1.day }
    shared_examples 'to create a new record' do
      it 'creates a new record' do
        Timecop.freeze(executed_at) do
          expect { testing_behaviour }
            .to(change { history_klass.count }.from(0).to(1))
          expect(instance.latest_history)
            .to have_attributes(expected_result)
        end
      end
    end
    context 'no histories are recorded' do
      let(:testing_behaviour) do
        instance.update_history(data_a.merge(unwatched_attribute: 1))
      end
      let(:expected_result) do
        data_a.merge(hoge_id: instance.id,
                     latest: true,
                     unwatched_attribute: 1,
                     first_watched_at: executed_at,
                     last_watched_at: executed_at,
                     last_touched_at: executed_at)
      end
      it_behaves_like 'to create a new record'
    end
    context 'no histories are recorded and pass base_time' do
      let(:testing_behaviour) do
        instance.update_history(data_a.merge(unwatched_attribute: 1), issued_at)
      end
      let(:expected_result) do
        data_a.merge(hoge_id: instance.id,
                     latest: true,
                     unwatched_attribute: 1,
                     first_watched_at: issued_at,
                     last_watched_at: issued_at,
                     last_touched_at: issued_at)
      end
      it_behaves_like 'to create a new record'
    end
    shared_examples 'to update the existed record' do
      it 'updates the existed record' do
        Timecop.freeze(executed_at) do
          expect { testing_behaviour }
            .to_not(change { history_klass.count })
          expect(instance.latest_history)
            .to have_attributes(expected_result)
        end
      end
    end
    context 'status is same as previous one' do
      let(:testing_behaviour) do
        instance.update_history(data_a.merge(unwatched_attribute: 1))
      end
      let(:expected_result) do
        data_a.merge(hoge_id: instance.id,
                     latest: true,
                     unwatched_attribute: 1,
                     first_watched_at: issued_at,
                     last_watched_at: executed_at,
                     last_touched_at: executed_at)
      end
      let!(:history) do
        history_klass.create!(data_a.merge(hoge: instance,
                                           unwatched_attribute: 0,
                                           first_watched_at: issued_at,
                                           last_watched_at: issued_at,
                                           last_touched_at: issued_at,
                                           latest: true))
      end
      it_behaves_like 'to update the existed record'
    end
    context 'status is same as previous one and pass base_time' do
      let(:testing_behaviour) do
        instance.update_history(data_a.merge(unwatched_attribute: 1), issued_at)
      end
      let(:expected_result) do
        data_a.merge(hoge_id: instance.id,
                     latest: true,
                     unwatched_attribute: 1,
                     first_watched_at: issued_at,
                     last_watched_at: issued_at,
                     last_touched_at: issued_at)
      end
      let!(:history) do
        history_klass.create!(data_a.merge(hoge: instance,
                                           unwatched_attribute: 0,
                                           first_watched_at: issued_at,
                                           last_watched_at: issued_at,
                                           last_touched_at: issued_at,
                                           latest: true))
      end
      it_behaves_like 'to update the existed record'
    end
    shared_examples 'to switch a new record' do
      it 'updates the existed record and creates a new record' do
        Timecop.freeze(executed_at) do
          expect { testing_behaviour }
            .to(change { history_klass.count }.from(1).to(2))
          expect(instance.latest_history)
            .to have_attributes(expected_result_new)
          expect(history_klass.find(history.id))
            .to have_attributes(expected_result_old)
        end
      end
    end
    context 'status is diff from previous one' do
      let(:testing_behaviour) do
        instance.update_history(data_a.merge(unwatched_attribute: 1))
      end
      let(:expected_result_new) do
        data_a.merge(hoge_id: instance.id,
                     latest: true,
                     unwatched_attribute: 1,
                     first_watched_at: executed_at,
                     last_watched_at: executed_at,
                     last_touched_at: executed_at)
      end
      let(:expected_result_old) do
        data_b.merge(hoge_id: instance.id,
                     latest: nil,
                     unwatched_attribute: 0,
                     first_watched_at: issued_at,
                     last_watched_at: issued_at,
                     last_touched_at: executed_at)
      end
      let!(:history) do
        history_klass.create!(data_b.merge(
                                hoge: instance,
                                unwatched_attribute: 0,
                                first_watched_at: issued_at,
                                last_watched_at: issued_at,
                                last_touched_at: issued_at,
                                latest: true,
        ))
      end
      it_behaves_like 'to switch a new record'
    end
    context 'status is diff from previous one and pass base_time' do
      let(:testing_behaviour) do
        instance.update_history(data_a.merge(unwatched_attribute: 1), issued_at)
      end
      let(:expected_result_new) do
        data_a.merge(hoge_id: instance.id,
                     latest: true,
                     unwatched_attribute: 1,
                     first_watched_at: issued_at,
                     last_watched_at: issued_at,
                     last_touched_at: issued_at)
      end
      let(:expected_result_old) do
        data_b.merge(hoge_id: instance.id,
                     latest: nil,
                     unwatched_attribute: 0,
                     first_watched_at: issued_at,
                     last_watched_at: issued_at,
                     last_touched_at: issued_at)
      end
      let!(:history) do
        history_klass.create!(data_b.merge(
                                hoge: instance,
                                unwatched_attribute: 0,
                                first_watched_at: issued_at,
                                last_watched_at: issued_at,
                                last_touched_at: issued_at,
                                latest: true,
        ))
      end
      it_behaves_like 'to switch a new record'
    end
  end
end
