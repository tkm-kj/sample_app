require 'spec_helper'

describe "Authentication" do
  subject { page }
  describe "signin page" do
    before { visit signin_path }
    it { should have_title('Sign in') }
    it { should have_content('Sign in') }

    describe '正しくない情報の時' do
      before { click_button 'Sign in' }
      it { should have_title('Sign in') }
      it { should have_error_message('Invalid') }

      describe '別のページの遷移する時、アラートが残らない' do
        before { click_link 'Home' }
        it { should_not have_error_message('Invalid') }
      end
    end

    describe '正しい情報の時' do
      let(:user) { FactoryGirl.create(:user) }
      before { valid_signin(user) }

      it { should have_title(user.name) }
      it { should have_link('Profile', href: user_path(user)) }
      it { should have_link('Sign out', href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) }

      describe 'サインアウトする時' do
        before { click_link 'Sign out' }
        it { should have_link('Sign in') }
      end
    end
  end
end
