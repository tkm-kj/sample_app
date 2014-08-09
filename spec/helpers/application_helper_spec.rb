require 'spec_helper'

describe ApplicationHelper do
  describe 'full_title' do
    it '引数で指定した文字列をタイトル最後に含んでいる' do
      expect(full_title('hoge')).to match(/| hoge$/)
    end
    it 'サイト名がタイトルの最初に付いている' do
      expect(full_title('hoge')).to match(/^Ruby on Rails Tutorial Sample App/)
    end
    it '引数なしの場合、バーがつかない' do
      expect(full_title('')).not_to match(/\|/)
    end
  end
 end