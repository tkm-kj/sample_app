require 'spec_helper'

describe "Static pages" do

  describe "Home page" do
    it "Sample Appという文字列が入っているかどうか" do
      visit '/static_pages/home'
      expect(page).to have_content('Sample App')
    end

    it '正しいタイトル名が表示される' do
      visit '/static_pages/home'
      expect(page).to have_title('Ruby on Rails Tutorial Sample App | Home')
    end

  end

  describe 'Help page' do
    it 'Helpという文字列が入っているか' do
      visit '/static_pages/help'
      expect(page).to have_content('Help')
    end

    it '正しいタイトル名が表示される' do
      visit '/static_pages/help'
      expect(page).to have_title('Ruby on Rails Tutorial Sample App | Help')
    end
  end

  describe 'About page' do
    it 'About Usという文字列が入っているかどうか' do
      visit '/static_pages/about'
      expect(page).to have_content('About Us')
    end

    it '正しいタイトル名が表示される' do
      visit '/static_pages/about'
      expect(page).to have_title('Ruby on Rails Tutorial Sample App | About Us')
    end
  end
end