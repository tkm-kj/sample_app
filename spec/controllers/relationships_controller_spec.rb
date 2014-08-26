require 'spec_helper'

describe RelationshipsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }

  before { sign_in user, no_capybara: true }

  describe 'ajaxでrelationshipを作成' do
    it 'Relationshipの数が増える' do
      expect do
        xhr :post, :create, relationship: { followed_id: other_user.id }
      end.to change(Relationship, :count).by(1)
    end

    it '成功のレスポンスが返ってくる' do
      xhr :post, :create, relationship: { followed_id: other_user.id }
      expect(response).to be_success
    end
  end

  describe 'ajaxでrelationshipを削除' do
    before { user.follow!(other_user) }
    let(:relationship) do
      user.relationships.find_by(followed_id: other_user.id)
    end

    it 'Relationshipの数が減る' do
      expect do
        xhr :delete, :destroy, id: relationship.id
      end.to change(Relationship, :count).by(-1)
    end

    it '成功のレスポンスが返ってくる' do
      xhr :delete, :destroy, id: relationship.id
      expect(response).to be_success
    end
  end
end