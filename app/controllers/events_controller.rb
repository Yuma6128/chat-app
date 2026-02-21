class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  def index
    @year = params[:year]&.to_i || Date.today.year
    @events = current_user.events
                          .where(event_date: Date.new(@year, 1, 1)..Date.new(@year, 12, 31))
                          .order(:event_date)
    @events_by_month = @events.group_by { |e| e.event_date.month }
  end

  def dashboard
    @upcoming_events = current_user.events.upcoming.limit(5)
    @overdue_tasks   = current_user.tasks.overdue.limit(10)
    @due_soon_tasks  = current_user.tasks.due_soon.limit(10)
    @next_actions    = build_next_actions
    @monthly_summary = monthly_summary
  end

  def show
    @tasks = @event.tasks.order(:due_date, :priority)
    @pending_tasks   = @tasks.active
    @completed_tasks = @tasks.completed
  end

  def new
    @event = current_user.events.build
  end

  def create
    @event = current_user.events.build(event_params)
    if @event.save
      @event.generate_tasks!(current_user) if params[:auto_tasks] == '1'
      redirect_to event_path(@event), notice: 'イベントを登録しました。AIが自動でタスクを生成しました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to event_path(@event), notice: 'イベントを更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy
    redirect_to events_path, notice: 'イベントを削除しました。'
  end

  private

  def set_event
    @event = current_user.events.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:title, :description, :event_date, :category, :status)
  end

  def build_next_actions
    actions = []

    # 期限超過タスク
    overdue = current_user.tasks.overdue.by_priority.limit(3)
    overdue.each do |task|
      actions << {
        type: :overdue,
        label: '期限超過',
        message: "【#{task.event.title}】#{task.title}",
        due: task.due_date,
        task: task
      }
    end

    # 直近7日以内のタスク
    due_soon = current_user.tasks.due_soon.by_priority.limit(5)
    due_soon.each do |task|
      d = task.days_until_due
      actions << {
        type: :urgent,
        label: d == 0 ? '本日期限' : "あと#{d}日",
        message: "【#{task.event.title}】#{task.title}",
        due: task.due_date,
        task: task
      }
    end

    # 今後30日以内のイベント
    upcoming = current_user.events.upcoming.where('event_date <= ?', Date.today + 30).limit(3)
    upcoming.each do |event|
      d = event.days_until
      next if d < 0
      pending_count = event.tasks.active.count
      if pending_count > 0
        actions << {
          type: :reminder,
          label: d == 0 ? '本日' : "#{d}日後",
          message: "「#{event.title}」まで#{d}日 — 残りタスク #{pending_count}件",
          event: event
        }
      end
    end

    actions
  end

  def monthly_summary
    (1..12).map do |m|
      {
        month: m,
        count: current_user.events.where(event_date: Date.new(Date.today.year, m, 1)..Date.new(Date.today.year, m, -1)).count
      }
    end
  end
end
