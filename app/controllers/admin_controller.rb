class AdminController < ApplicationController
  def stats
    result = Session.group(:generated_playlist).count

    if result.count == 2
      true_count = result[true].to_i
      false_count = result[false].to_i
    elsif result.count == 1
      if (!result[true].nil?)
        true_count = result[true].to_i
        false_count = 0
      else
        true_count = 0
        false_count = result[false].to_i
      end
    else
      true_count = 0
      false_count = 0
    end

    total = true_count + false_count

    @stats = {:true => {absolute: true_count, percent: (total > 0 ? 100 * true_count / total : 0)}, :false =>
        {absolute: false_count, percent: (total > 0 ? 100 * false_count / total : 0)}}
  end
end
