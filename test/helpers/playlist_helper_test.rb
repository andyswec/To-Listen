require 'test_helper'
require 'rspotify'

class PlaylistHelperTest < ActionView::TestCase
  include PlaylistHelper

  @@user = nil
  @@track = nil
  @@track_with_all_artists = nil
  @@track_with_one_artist = nil
  @@other_track = nil

  def setup
    return unless @@user.nil? || @@track.nil? || @@track_with_all_artists.nil? || @@track_with_one_artist.nil? || @@other_track.nil?

    RSpotify::authenticate(ENV['spotify_client_id'], ENV['spotify_client_secret'])
    @@user = SpotifyLastFmUser.new(spotify_user: spotify_users(:andy))
    @@track = RSpotify::Track.find('3OwPSJu609AMzotCEyoMiO') # Avicii - The Nights
    @@track_with_all_artists = RSpotify::Track.find('7HW01sQy5UOxyezzZg98nd') # Avicii - The Days
    @@track_with_one_artist = RSpotify::Track.find('007lsEHi6fP9LoYB7czYUa') # Wycleaf, Avicii - Divine Sorrow
    @@other_track = RSpotify::Track.find('6AJlcxjEO2baFC24GPsJjg') # Bonnie Tyler - Holding Out for a Hero
  end

  test 'should return 1 as similarity between identical songs' do
    value = @@track.similarity(@@track)
    assert value == 1, 'Expected 1 but found ' + value.to_s
  end

  test 'should return 0.5 as similarity between songs sang by the same artists' do
    value = @@track.similarity(@@track_with_all_artists)
    assert value == 0.5, 'Expected 0.5 but found ' + value.to_s
  end

  test 'should return 0.25 as similarity between songs where at least one artist is the same' do
    value = @@track.similarity(@@track_with_one_artist)
    assert value == 0.25, 'Expected 0.25 but found ' + value.to_s
  end

  test 'should return 0 as similarity between songs sang by other artists' do
    value = @@track.similarity(@@other_track)
    assert value == 0, 'Expected 0 but found ' + value.to_s
  end

  test 'should return 1 as time coefficient for a date after now' do
    value = SpotifyLastFmUser.time_coefficient(Time.now.end_of_day)
    assert value == 1, 'Expected 1 but found ' + value.to_s
  end

  test 'should return 1 as time coefficient for a date 2 weeks ago' do
    value = SpotifyLastFmUser.time_coefficient(Time.now.advance weeks: -2)
    assert value == 1, 'Expected 1 but found ' + value.to_s
  end

  test 'should return 0.5 as time coefficient for a date 4 weeks ago' do
    value = SpotifyLastFmUser.time_coefficient(Time.now.advance weeks: -4)
    assert value == 0.5, 'Expected 0.5 but found ' + value.to_s
  end

  test 'should return 0.25 as time coefficient for a date 6 weeks ago' do
    value = SpotifyLastFmUser.time_coefficient(Time.now.advance weeks: -6)
    assert value == 1/3.to_f, 'Expected ' + (1/3.to_f).to_s + ' but found ' + value.to_s
  end

  test 'should get relevance' do
    assert_not_nil @@user.send(:relevance, @@track)
    assert_not_nil @@user.send(:relevance, @@track_with_all_artists)
    assert_not_nil @@user.send(:relevance, @@track_with_one_artist)
    assert_not_nil @@user.send(:relevance, @@other_track)
  end

  test 'should convert track to string' do
    assert_not_empty @@track.to_s
    assert_not_empty @@track_with_all_artists.to_s
    assert_not_empty @@track_with_one_artist.to_s
    assert_not_empty @@other_track.to_s
  end
end
