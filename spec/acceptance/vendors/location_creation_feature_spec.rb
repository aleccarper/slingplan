require 'rails_helper'

describe 'the location creation process', type: :feature, js: true do
  before :each do
    Timecop.travel DateTime.parse('01/01/2050')
  end
  after :each do
    Timecop.return
  end

  it 'creates the location properly' do
    visit root_path

    click_link 'Sign In'

    within '#new_vendor' do
      fill_in 'vendor[email]', with: 'test1@example.com'
      fill_in 'vendor[password]', with: 'test1_pw'

      click_button 'Sign In'
    end

    click_link 'New'

    within '#new_location' do
      fill_in 'location[name]', with: 'testname'
      fill_in 'location[address1]', with: 'testaddress1'
      fill_in 'location[address2]', with: 'testaddress2'
      fill_in 'location[city]', with: 'testcity'
      select 'AR', from: 'location[state]'
      fill_in 'location[zip]', with: '72116'
      fill_in 'location[email]', with: 'test@email.com'
      fill_in 'location[website]', with: 'www.test.com'
      check 'location[service_ids][]'

      click_button 'Add'
    end

    click_link 'Confirm'

    page.should have_selector '.left.btn.btn-new-location'
  end
end
