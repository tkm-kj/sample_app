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
      it { should have_link('Users', href: users_path) }
      it { should have_link('Profile', href: user_path(user)) }
      it { should have_link('Setting', href: edit_user_path(user)) }
      it { should have_link('Sign out', href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) }

      describe 'サインアウトする時' do
        before { click_link 'Sign out' }
        it { should have_link('Sign in') }
      end
    end
  end

  describe '認証' do
    describe 'サインインしていない状態' do
      let(:user) { FactoryGirl.create(:user) }
      describe 'Users controller内の処理を行う' do
        describe 'edit pageに移動' do
          before { visit edit_user_path(user) }
          it { should have_title('Sign in') }
        end

        describe 'updateアクションを実行' do
          before { patch user_path(user) }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe 'indexアクションを実行' do
          before { visit users_path }
          it { should have_title('Sign in') }
        end
      end

      describe 'Microposts controller内の処理を行う' do
        describe 'createアクションを実行' do
          before { post microposts_path }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe 'destroyアクションを実行' do
          before { delete micropost_path(FactoryGirl.create(:micropost)) }
          specify { expect(response).to redirect_to(signin_path) }
        end
      end

      describe '保護されたページに行くとき' do
        before do
          visit edit_user_path(user)
          fill_in 'Email', with: user.email
          fill_in 'Password', with: user.password
          click_button 'Sign in'
        end

        describe 'サインインした後' do
          it 'フレンドリーフォワーディングする' do
            expect(page).to have_title('Edit user')
          end

          describe '再びサインインする' do
            before do
              delete signout_path
              visit signin_path
              fill_in 'Email', with: user.email
              fill_in 'Password', with: user.password
              click_button 'Sign in'
            end
            it 'デフォルトページに遷移' do
              expect(page).to have_title(user.name)
            end
          end
        end

      end
    end

    describe '正しくないユーザーに対する処理' do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: 'wrong@example.com') }
      before { sign_in user, no_capybara: true }
      describe 'GET users#edit' do
        before { get edit_user_path(wrong_user) }
        specify { expect(response.body).not_to match(full_title('Edit user')) }
        specify { expect(response).to redirect_to(root_path) }
      end

      describe 'PATCH users#update' do
        before { patch user_path(wrong_user) }
        specify { expect(response).to redirect_to(root_path) }
      end
    end

    describe 'adminユーザーでない時' do
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }

      before { sign_in non_admin, no_capybara: true }

      describe 'users#destroyを実行し削除できないようにする' do
        before { delete user_path(user) }
        specify { expect(response).to redirect_to root_path }
      end
    end
  end

end
