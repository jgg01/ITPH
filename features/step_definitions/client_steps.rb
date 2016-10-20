Given(/^the following clients exist:$/) do |table|
  # table is a Cucumber::MultilineArgument::DataTable
  table.hashes.each do |client|
    Client.create!(client)
  end
end

Given(/^(.*) has an appointment with me on (.*)$/) do |client_name, date|
  client = Client.where(name: client_name)
  client.make_appointment("Toni", date)
end

Then(/^I should see an upcoming appointment for (.*)$/) do |date|
  expect(page.should have_content date)
end

Given(/^the phone number of (.*) is (\d{3}-\d{3}-\d{4})$/) do |client_name, number|
  client = Client.where(name: client_name)
  expect(client.phone_number).to be(number)
end

Then(/^I should see the phone number is (\d{3}-\d{3}-\d{4})$/) do |date|
  expect(page.should have_content date)
end

Then(/^I should see the counselor is (.*)$/) do |counselor|
  expect(page.should have_content counselor)
end

Then(/^I change the counselor to (.*)$/) do |c|
  find(:css, "input[name='client[counselor]']").set(c)
end

Then(/^I change the phone number to (\d{3}-\d{3}-\d{4})$/) do |phone|
  find(:css, "input[name='client[phone_number]']").set(phone)
end

Then(/^I change the email to "([^"]*)"$/) do |client_email|
  find(:css, "input[name='client[email]']").set(client_email)
end

Then(/^I should see an error$/) do
  expect(flash[:notice]).to be_present
end

Then(/^I should see the email is "([^"]*)"$/) do |email|
  expect(page.should have_content email)
end

When(/^I search for "([^"]*)"$/) do |arg1|
  fill_in(search_bar, :with => arg1)
  click_button("search")
end

Then(/^I should see the following emails:(.*)$/) do |email_list|
  email_list.split(", ").each do |email|
      expect(page.should have_content email)
  end
end

Then(/^I should see no upcoming appointments$/) do
  expect page.should_not have_content "Next Appointment"
end

