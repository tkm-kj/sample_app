require 'spec_helper'

describe "Micropost pages" do
  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe 'micropost作成' do
    before { visit root_path }

    describe '妥当じゃない情報の時' do
      it 'micropostを作れない' do
        expect { click_button 'Post' }.not_to change(Micropost, :count)
      end

      describe 'エラーメッセージ' do
        before { click_button 'Post' }
        it { should have_content('error') }
      end
    end

    describe '妥当な情報の時' do
      before do
        fill_in 'micropost_content', with: 'hoge'
      end
      it 'micropostを作成できる' do
        expect { click_button 'Post' }.to change(Micropost, :count).by(1)
      end
    end
  end

  describe 'micropost削除' do
    before do
      FactoryGirl.create(:micropost, user: user)
      visit root_path
    end

    describe '削除を行うユーザーが正しい時' do
      it '削除が正しく行われる' do
        expect { click_link 'delete' }.to change(Micropost, :count).by(-1)
      end
    end
  end
end
