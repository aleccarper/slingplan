require 'rails_helper'

describe 'staffer registration', type: :feature, js: true do

  it 'works' do
    mock_geocoding!

    visit('/')

    click_link('Register')

    then_wait_for_page_change { click_link('Staffer') }

    within('#new_staffer') do
      fill_in('staffer[email]', with: 'definitely@new.com')
      fill_in('staffer[password]', with: 'asdf1234')
      fill_in('staffer[password_confirmation]', with: 'asdf1234')
      fill_in('staffer[name]', with: 'TestName')
      fill_in('staffer[address1]', with: '123 Test Ln.')
      fill_in('staffer[city]', with: 'North Little Rock')
      select('Arkansas', from: 'staffer_state')
      fill_in('staffer[zip]', with: '72116')
      fill_in('staffer[primary_phone_number]', with: '5555555555')
      fill_in('staffer[primary_email]', with: 'test@test.com')
      fill_in('staffer[primary_website]', with: 'www.test.com')
      fill_in('staffer[description]', with: 'test description')
      select('Central Time (US & Canada)', from: 'staffer[time_zone]')

      page.execute_script "$('#staffer_accepted_terms_of_service').click()"

      then_wait_for_page_change { click_button('Next') }
    end

    within('#credit-card-form') do
      page.execute_script "$('.price[data-id=\"tier1y\"]').click()"

      fill_in('stripe_number', with: '4242424242424242')
      select('07', from: 'exp_month')
      fill_in('stripe_cvc', with: '123')

      then_wait_for_page_change { click_button('Finish!') }
    end

    expect(page).to have_selector('.tip.link-sign-out')
  end

end
