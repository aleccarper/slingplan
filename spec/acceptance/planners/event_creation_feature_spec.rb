require 'rails_helper'

describe 'the event creation process', type: :feature, js: true do
  before :each do
    Timecop.travel DateTime.parse('01/01/2050')
  end
  after :each do
    Timecop.return
  end

  it 'creates the event properly' do
    mock_geocoding!

    planner = create(:planner)
    vendor = create(:vendor)

    visit root_path

    then_wait_for_page_change { click_link 'Sign In' }

    expect(current_path).to eq(signin_index_path)

    then_wait_for_page_change {
      within '#new_planner' do
        fill_in 'Email', with: planner.email
        fill_in 'Password', with: planner.password

        click_button 'Sign In'
      end
    }

    expect(current_path).to eq(planners_admin_events_path)

    then_wait_for_page_change { page.first('.btn-new-event').click }

    expect(current_path).to eq(new_planners_admin_event_path)

    within '#new_event' do
      fill_in 'Event Name', with: 'Test Name'
      fill_in 'City', with: 'Little Rock'
      select 'Arkansas', from: 'event_state'
      select 'United States of America', from: 'Country Code'
      fill_in 'Address1', with: '1508 War Eagle Dr.'
      fill_in 'Address2', with: ''
      fill_in 'Zip', with: '72116'

      page.execute_script "$('.date .after-today').first().click()"

      wait_for_ajax

      vendor.locations.first.services.map(&:id).each do |service_id|
        page.execute_script "$('\#event_service_ids_#{service_id}').prop('checked', true)"
      end

      click_button 'Next'

      wait_for_ajax
    end

    # expect(page.has_css?('.new_confirm')).to eq(true)

    # planner.events.last.service_rfps.each do |srfp|

    #   within("\#edit_service_rfp_#{srfp.id}") do
    #     fill_in('service_rfp[notes]', with: "notes #{srfp.id}")
    #     fill_in('service_rfp[bid]', with: '1000')
    #     fill_in('#service_rfp_radius', with: '200')
    #   end
    # end

    # then_wait_for_page_change {
    #   click_button 'Confirm'
    # }

    # expect(planner.events.last.name).to eq('Test Name')
  end
end
