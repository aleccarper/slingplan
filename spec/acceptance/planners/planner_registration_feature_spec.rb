require 'rails_helper'

describe 'planner registration', type: :feature, js: true do

  it 'works' do
    mock_geocoding!

    visit('/')

    click_link('Register')

    then_wait_for_page_change { click_link('Planner') }

    within('#new_planner') do
      fill_in('planner[email]', with: 'definitely@nottaken.com')
      fill_in('planner[password]', with: 'asdf1234')
      fill_in('planner[password_confirmation]', with: 'asdf1234')
      fill_in('planner[first_name]', with: 'test')
      fill_in('planner[last_name]', with: 'Kennedy')
      fill_in('planner[primary_email]', with: 'test@test.com')
      fill_in('planner[primary_website]', with: 'www.test.com')
      select('Central Time (US & Canada)', from: 'planner_time_zone')
      fill_in('planner[description]', with: 'test description')

      page.execute_script "$('#planner_accepted_terms_of_service').click()"

      then_wait_for_page_change { click_button('Sign up') }
    end

    within('#credit-card-form') do
      page.execute_script "$('.price[data-id=\"tier2y\"]').click()"

      fill_in('stripe_number', with: '4242424242424242')
      select('07', from: 'exp_month')
      fill_in('stripe_cvc', with: '123')

      then_wait_for_page_change { click_button('Subscribe') }
    end

    expect(page).to have_selector('.tip.link-sign-out')
  end

end
