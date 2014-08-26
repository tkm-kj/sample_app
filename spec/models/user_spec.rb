require 'spec_helper'

describe User do
  before do
    @user = User.new(name: 'Example', email: 'example@gmail.com', password: 'foobar', password_confirmation: 'foobar')
  end

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:admin) }
  it { should respond_to(:microposts) }
  it { should respond_to(:feed) }
  it { should respond_to(:relationships) }
  it { should respond_to(:followed_users) }
  it { should respond_to(:reverse_relationships) }
  it { should respond_to(:followers) }
  it { should respond_to(:following?) }
  it { should respond_to(:follow!) }
  it { should respond_to(:unfollow!) }

  it { should be_valid }
  it { should_not be_admin }

  describe 'admin属性をtrueにする' do
    before do
      @user.save!
      @user.toggle!(:admin)
    end
    it { should be_admin }

  end

  describe '名前が空の時' do
    before { @user.name = '' }
    it { should_not be_valid }
  end
  describe '名前が50文字より大きい時' do
    before { @user.name = 'a' * 51 }
    it { should_not be_valid }
  end

  describe 'Emailが空の時' do
    before { @user.email = '' }
    it { should_not be_valid }
  end

  describe "Emailのフォーマットテスト" do
    it "妥当でない時" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).not_to be_valid
      end
    end

    it '妥当な時' do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end

  describe 'Emailの重複登録が行われる場合' do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end
    it { should_not be_valid }
  end

  describe 'Emailの文字列が大文字と小文字がバラバラの場合' do
    let(:mixed_case_email) { 'Foo@ExAMPle.CoM' }
    it '保存前にすべての文字列が小文字になる' do
      @user.email = mixed_case_email
      @user.save
      expect(@user.reload.email).to eq mixed_case_email.downcase
    end

  end

  describe 'passwordが空の時' do
    before do
      @user = User.new(name: 'Example', email: 'example@gmail.com', password: '', password_confirmation: '')
    end
    it { should_not be_valid }
  end

  describe 'password_confirmationとpasswordが不一致の時' do
    before do
      @user.password_confirmation = 'mismatch'
    end
    it { should_not be_valid }
  end

  describe 'authenticateメソッドのテスト' do
    before { @user.save }
    let(:found_user) { User.find_by(email: @user.email) }

    describe '妥当なパスワードの時' do
      it { should eq found_user.authenticate(@user.password) }
    end

    describe '妥当でないパスワードの時' do
      let(:user_for_invalid_password) { found_user.authenticate('invalid') }
      it { should_not eq user_for_invalid_password }
      specify { expect(user_for_invalid_password).to be_false }
    end
  end

  describe 'パスワードが短すぎる時' do
    before { @user.password = @user.password_confirmation = 'a' * 5 }
    it { should be_invalid }
  end

  describe 'トークンを記憶する' do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end

  describe 'micropostの関連付け' do
    before { @user.save }
    let!(:older_micropost) do
      FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
    end
    let!(:newer_micropost) do
      FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
    end

    it '正しい順番でmicropostが返ってくる' do
      expect(@user.microposts.to_a).to eq [newer_micropost, older_micropost]
    end

    it 'userを消したら関連するmicropostsも消える' do
      microposts = @user.microposts.to_a
      @user.destroy
      expect(microposts).not_to be_empty
      microposts.each do |micropost|
        expect(Micropost.where(id: micropost.id)).to be_empty
      end
    end

    describe 'feed' do
      let(:unfollowed_post) do
        FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
      end
      its(:feed) { should include(newer_micropost) }
      its(:feed) { should include(older_micropost) }
      its(:feed) { should_not include(unfollowed_post) }
    end

    describe 'status' do
      let(:unfollowed_post) do
        FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
      end
      let(:followed_user) { FactoryGirl.create(:user) }

      before do
        @user.follow!(followed_user)
        3.times { followed_user.microposts.create!(content: 'hoge') }
      end
      its(:feed) { should include(newer_micropost) }
      its(:feed) { should include(older_micropost) }
      its(:feed) { should_not include(unfollowed_post) }
      its(:feed) do
        followed_user.microposts.each do |micropost|
          should include(micropost)
        end
      end
    end
  end

  describe 'following' do
    let(:other_user) { FactoryGirl.create(:user) }
    before do
      @user.save
      @user.follow!(other_user)
    end
    it { should be_following(other_user) }
    its(:followed_users) { should include(other_user) }

    describe 'followed user' do
      subject { other_user }
      its(:followers) { should include(@user) }
    end

    describe 'unfollow' do
      before { @user.unfollow!(other_user) }
      it { should_not be_following(other_user) }
      its(:followed_users) { should_not include(other_user) }
    end
  end
end
