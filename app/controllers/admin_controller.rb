class AdminController < ApplicationController
  def stats
    result = Session.connection.execute("SELECT generated_playlist as value, COUNT(*) FROM sessions GROUP BY
generated_playlist ORDER BY value DESC")

    if result.count == 2
      true_count = result.first['count'].to_i
      false_count = result.last['count'].to_i
    else
      result = result.first
      if (result['value'] == 't')
        true_count = result['count'].to_i
        false_count = 0
      else
        true_count = 0
        false_count = result['count'].to_i
      end
    end

    total = true_count + false_count

    @stats = {:true => {absolute: true_count, percent: 100 * true_count / total}, :false => {absolute: false_count,
        percent: 100 * false_count / total}}
  end
end
