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

  it { should be_valid }

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
end
