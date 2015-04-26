require 'test_helper'

class SessionTest < ActiveSupport::TestCase

  def setup
    @session = Session.new(id: 'abcdefgh')
  end

  test 'id should be present' do
    @session.id = nil
    assert_not @session.valid?
  end

  test 'ids should be unique' do
    duplicate_session = @session.dup
    duplicate_session.id = @session.id
    @session.save
    assert_not duplicate_session.valid?
  end
end
