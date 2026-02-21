class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event
  before_action :set_task, only: [:edit, :update, :destroy]

  def create
    @task = @event.tasks.build(task_params)
    @task.user = current_user
    if @task.save
      redirect_to event_path(@event), notice: 'タスクを追加しました。'
    else
      redirect_to event_path(@event), alert: 'タスクの追加に失敗しました。'
    end
  end

  def edit
  end

  def update
    if @task.update(task_params)
      redirect_to event_path(@event), notice: 'タスクを更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    redirect_to event_path(@event), notice: 'タスクを削除しました。'
  end

  def toggle_status
    @task = @event.tasks.find(params[:id])
    new_status = @task.status == 'completed' ? 'pending' : 'completed'
    @task.update!(status: new_status)
    redirect_to event_path(@event), notice: new_status == 'completed' ? 'タスクを完了しました！' : 'タスクを未完了に戻しました。'
  end

  private

  def set_event
    @event = current_user.events.find(params[:event_id])
  end

  def set_task
    @task = @event.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :due_date, :status, :priority)
  end
end
