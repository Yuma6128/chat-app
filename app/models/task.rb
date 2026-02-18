class Task < ApplicationRecord
  belongs_to :event
  belongs_to :user

  STATUSES = {
    'pending'     => '未着手',
    'in_progress' => '進行中',
    'completed'   => '完了',
    'overdue'     => '期限超過'
  }.freeze

  PRIORITIES = {
    1 => '高',
    2 => '中',
    3 => '低'
  }.freeze

  validates :title, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES.keys }
  validates :priority, presence: true, inclusion: { in: PRIORITIES.keys }

  scope :pending, -> { where(status: %w[pending overdue]) }
  scope :active, -> { where(status: %w[pending in_progress overdue]) }
  scope :completed, -> { where(status: 'completed') }
  scope :overdue, -> { where('due_date < ? AND status != ?', Date.today, 'completed').order(:due_date) }
  scope :due_soon, -> { where('due_date BETWEEN ? AND ? AND status != ?', Date.today, Date.today + 7.days, 'completed').order(:due_date) }
  scope :by_priority, -> { order(:priority, :due_date) }

  def status_label
    STATUSES[status] || status
  end

  def priority_label
    PRIORITIES[priority] || priority.to_s
  end

  def days_until_due
    return nil unless due_date
    (due_date - Date.today).to_i
  end

  def overdue?
    due_date && due_date < Date.today && status != 'completed'
  end

  def urgency_level
    return :done if status == 'completed'
    return :overdue if overdue?
    d = days_until_due
    return :normal unless d
    if d <= 3
      :critical
    elsif d <= 7
      :urgent
    elsif d <= 14
      :soon
    else
      :normal
    end
  end
end
