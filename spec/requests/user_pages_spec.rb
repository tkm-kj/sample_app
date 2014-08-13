require 'spec_helper'

describe "User pages" do
  subject { page }
  describe 'profile page' do
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }

    it { should have_content(user.name) }
    it { should have_title(user.name) }
  end

  describe "signup page" do
    before { visit signup_path }

    describe '正しくない情報でユーザー登録が行われる時' do
      it 'ユーザー数が変化しない' do
        expect { click_button submit }.not_to change(User, :count)
      end
    end

    describe '正しい情報でユーザー登録が行われる時' do
      before do
        fill_in 'Name', with: 'Example User'
        fill_in 'Email', with: 'user@example.com'
        fill_in 'Password', with: 'foobar'
        fill_in 'Confirmation', with: 'foobar'
      end

      it 'ユーザー数が1増える' do
        expect { click_button submit }.to change(User, :count).by(1)
      end
    end
    it { should have_content('Sign up') }
    it { should have_title(full_title('Sign up')) }


  end
end
