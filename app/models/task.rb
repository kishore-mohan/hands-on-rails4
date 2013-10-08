class Task < ActiveRecord::Base

  has_many :logs, :dependent => :destroy
  belongs_to :project

  default_scope {order(:done,:created_at => :desc)}

  validates :name,:project ,:presence => true

  def work?
    !logs.empty? && !logs.first.stop
  end

  def logged
    logs.map(&:duration).sum
  end

end
