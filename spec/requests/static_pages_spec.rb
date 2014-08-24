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
      expect(page).to have_title(full_title('Sign in'))
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

    describe 'ユーザーがサインインしている場合' do
      let(:user) { FactoryGirl.create(:user) }
      before do
        FactoryGirl.create(:micropost, user: user, content: 'hoge')
        FactoryGirl.create(:micropost, user: user, content: 'fuga')
        sign_in user
        visit root_path
      end
      it { should have_content(user.name) }
      it 'ユーザーのfeedが表示される' do
        user.feed.paginate(page: 1).each do |item|
          expect(page).to have_selector("li##{item.id}", text: item.content)
        end
      end
      it '適切なfeed数が表示されるr' do
        expect(page).to have_content(user.microposts.count)
      end
    end
  end

  describe 'Help page' do
    before { visit help_path }
    it { should have_content('Help') }
    it { should have_title(full_title('Help')) }
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