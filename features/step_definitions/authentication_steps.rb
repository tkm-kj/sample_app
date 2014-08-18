Given /^サインインページに飛ぶお$/ do
  visit signin_path
end

When /^he submits invalid signin information$/ do
  click_button 'Sign in'
end

Then /^he should see an error message$/ do
  expect(page).to have_selector('div.alert.alert-error', text: 'Invalid')
end

And /^the user has an account$/ do
  @user = User.create(name: 'example', email: 'example@hoge.com', password: 'password', password_confirmation: 'password')
end

When /^the user submits valid signin information$/ do
  fill_in 'Email', with: @user.email
  fill_in 'Password', with: @user.password
  click_button 'Sign in'
end

Then /^he should see his profile page$/ do
  expect(page).to have_title(@user.name)
end

And /^he should see a signout link$/ do
  expect(page).to have_link('Sign out')
end