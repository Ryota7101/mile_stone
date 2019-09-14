class TasksController < ApplicationController
  #プロジェクト内で管理するタスク機能
  
  before_action :set_task, only: [:show, :edit, :update, :destroy]
  
  def new
    @task = Task.new
    @task.project_id = params[:project_id]
  end
  
  def create
    @task = Task.new(task_params)
    @task.user = current_user
    if @task.save
      flash[:success] = "タスクの作成に成功しました"
      redirect_to task_path(@task)
    else
      render 'new'
    end
  end
  
  def index
    @tasks = Task.all
  end
  
  
  def show
    @task = Task.find(params[:id])
  end
  
  def edit
  end
  
  def update
  end
  
  def destroy
  end
  
  private
    def set_task
        @task = Task.find(params[:id])
    end
    
    def task_params
      params.require(:task).permit(:title, :limit, :project_id, category_ids: [])
    end
end
