require 'spec_helper'

describe "User pages" do
  subject { page }
  describe 'profile page' do
    let(:user) { FactoryGirl.create(:user) }
    let(:another_user) { FactoryGirl.create(:user) }
    let!(:m1) { FactoryGirl.create(:micropost, user: user, content: 'foo') }
    let!(:m2) { FactoryGirl.create(:micropost, user: user, content: 'bar') }
    let!(:am) { FactoryGirl.create(:micropost, user: another_user, content: 'homo') }

    before { visit user_path(user) }

    it { should have_content(user.name) }
    it { should have_title(user.name) }

    describe 'microposts' do
      it { should have_content(m1.content) }
      it { should have_content(m2.content) }
      it { should have_content(user.microposts.count) }
      it { should_not have_content('delete', href: micropost_path(user.microposts.first)) }
    end

    describe 'ログインする' do
      before do
        sign_in user
      end
      it '削除リンクが表示される' do
        expect(page).to have_link('delete', href: micropost_path(user.microposts.first))
      end
      describe '別のユーザーのprofileに飛ぶ' do
        before { visit user_path(another_user) }

        it '削除リンクが表示されない' do
          expect(page).not_to have_link('delete', href: micropost_path(another_user.microposts.first))

        end
      end
    end
  end

  describe "signup page" do
    it { should have_content('Sign up') }
    it { should have_title(full_title('Sign up')) }
    before { visit signup_path }
    let(:submit) { 'Create my account' }
    describe '正しくない情報でユーザー登録が行われる時' do
      it 'ユーザー数が変化しない' do
        expect { click_button submit }.not_to change(User, :count)
      end
      describe 'submitした後' do
        before { click_button submit }
        it { should have_title('Sign up') }
        it { should have_content('error') }
      end
    end

    describe '正しい情報でユーザー登録が行われる時' do
      before do
        fill_in 'Name', with: 'Example User'
        fill_in 'Email', with: 'user@example.com'
        fill_in 'Password', with: 'foobar'
        fill_in 'Confirm Password', with: 'foobar'
      end

      it 'ユーザー数が1増える' do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe 'ユーザーを保存した後' do
        before { click_button submit }
        let(:user) { User.find_by(email: 'user@example.com') }

        it { should have_link('Sign out') }
        it { should have_title(user.name) }
        it { should have_selector('.alert.alert-success', text: 'Welcome')}
      end
    end
  end

  describe 'edit' do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user)
    end

    describe 'page' do
      it { should have_content('Update your profile') }
      it { should have_title('Edit user') }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    describe '間違った情報の時' do
      before { click_button 'Save changes' }
      it { should have_content('error') }
    end

    describe '正しい情報の時' do
      let(:new_name) { 'Hoge' }
      let(:new_email) { 'hoge@example.com' }
      before do
        fill_in 'Name', with: new_name
        fill_in 'Email', with: new_email
        fill_in 'Password', with: user.password
        fill_in 'Confirm Password', with: user.password
        click_button 'Save changes'
      end
      it { should have_title(new_name) }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Sign out', href: signout_path) }
      specify { expect(user.reload.name).to eq new_name }
      specify { expect(user.reload.email).to eq new_email }
    end

    describe '管理者属性に変更できない' do
      let(:params) do
        { user: { admin: true, password: user.password, password_confirmation: user.password } }
      end
      before do
        sign_in user, no_capybara: true
        patch user_path(user), params
      end
      specify { expect(user.reload).not_to be_admin }
    end
  end

  describe 'index' do
    before(:each) do
      sign_in FactoryGirl.create(:user)
      visit users_path
    end

    it { should have_title('All users') }
    it { should have_content('All users')}

    describe 'ページネーション' do
      before(:all) { 30.times { FactoryGirl.create(:user) } }
      after(:all) { User.delete_all }

      it { should have_selector('div.pagination') }

      it 'リスト形式でユーザーが表示される' do
        User.paginate(page: 1).each do |user|
          expect(page).to have_selector('li', text:user.name)
        end
      end
    end

    describe 'ユーザー削除リンク' do
      it { should_not have_link('delete') }

      describe '管理者ユーザー' do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path
        end

        it { should have_link('delete', href: user_path(User.first)) }
        it '他のユーザーを削除できる' do
          expect do
            click_link('delete', match: :first)
          end.to change(User, :count).by(-1)
        end
        it { should_not have_link('delete', href: user_path(admin)) }

        it '管理者自身を削除できない' do
          expect do
            delete user_path(admin)
          end.not_to change(User, :count).by(-1)
        end
      end
    end

  end
end
