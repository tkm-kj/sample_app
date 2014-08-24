require 'spec_helper'

describe Micropost do
  let(:user) { FactoryGirl.create(:user) }
  before do
    @micropost = user.microposts.build(content: 'hoge')
  end

  subject { @micropost }

  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }
  its(:user) { should eq user }

  it { should be_valid }

  describe 'user_idが存在していない場合' do
    before { @micropost.user_id = nil }
    it { should_not be_valid }
  end

  describe 'contentは140文字以内' do
    before do
      @micropost.content = 'a' * 141
    end
    it { should_not be_valid }
  end
end
