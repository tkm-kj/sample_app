require 'spec_helper'

describe "Static pages" do
  let(:base_title) {'Ruby on Rails Tutorial Sample App'}
  describe "Home page" do
    it "Sample Appという文字列が入っているかどうか" do
      visit '/static_pages/home'
      expect(page).to have_content('Sample App')
    end

    it '正しいタイトル名が表示される' do
      visit '/static_pages/home'
      expect(page).to have_title("#{base_title}")
    end

    it 'Homeという文字列が入らない' do
      visit '/static_pages/home'
      expect(page).not_to have_title("| Home")
    end

  end

  describe 'Help page' do
    it 'Helpという文字列が入っているか' do
      visit '/static_pages/help'
      expect(page).to have_content('Help')
    end

    it '正しいタイトル名が表示される' do
      visit '/static_pages/help'
      expect(page).to have_title("#{base_title} | Help")
    end
  end

  describe 'About page' do
    it 'About Usという文字列が入っているかどうか' do
      visit '/static_pages/about'
      expect(page).to have_content('About Us')
    end

    it '正しいタイトル名が表示される' do
      visit '/static_pages/about'
      expect(page).to have_title("#{base_title} | About Us")
    end
  end

  describe 'Contact page' do
    it 'Contactという文字列が入っている' do
      visit '/static_pages/contact'
      expect(page).to have_content('Contact')
    end

    it '正しいタイトル名が表示される' do
      visit '/static_pages/contact'
      expect(page).to have_title("#{base_title} | Contact")
    end
  end
end