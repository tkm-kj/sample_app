require 'spec_helper'

describe "Static pages" do
  subject { page }

  describe 'Header and Footer' do
    it '正しいページに遷移する' do
      visit root_path
      click_link "Home"
      expect(page).to have_title(full_title(''))
      click_link "Help"
      expect(page).to have_title(full_title('Help'))
      click_link "Sign in"
      expect(page).to have_title(full_title('Sign up'))
      click_link "About"
      expect(page).to have_title(full_title('About Us'))
      click_link "Contact"
      expect(page).to have_title(full_title('Contact'))
    end
  end

  describe "Home page" do
    before { visit root_path }
    it { should have_content('Sample App') }
    it { should have_title(full_title('')) }
    it { should_not have_title("| Home") }
  end

  describe 'Help page' do
    before { visit help_path }
    it { should have_content('Help') }
    it { should have_title(full_title('Help')) }
  end

  describe 'Sign in page' do
    before { visit signup_path }
    it { should have_content('Sign up') }
    it { should have_title(full_title('Sign up')) }
  end

  describe 'About page' do
    before { visit about_path }
    it { should have_content('About Us') }
    it { should have_title(full_title('About Us')) }
  end

  describe 'Contact page' do
    before { visit contact_path }
    it { should have_content('Contact') }
    it { should have_title(full_title('Contact')) }
  end
end