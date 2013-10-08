class Log < ActiveRecord::Base

  belongs_to :task

  default_scope { order(:stop)}

  validates :task, :presence => true

  def duration
    ((stop? ? stop.to_time : Time.now) - start.to_time).to_i
  end
end
