class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy]
  
  def new
    @task = Task.new
    @task.project_id = params[:project_id]
  end
  
  def create
    @task = Task.new(task_params)
    @task.user = current_user
    if @task.save
      flash[:success] = "成功しました"
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
    #@article = Article.find(params[:id])
  end
  
  def update
    #@article = Article.find(params[:id])
  end
  
  def destroy
    #@article = Article.find(params[:id])
  end
  
  private
    def set_task
        @task = Task.find(params[:id])
    end
    
    def task_params
      params.require(:task).permit(:title, :limit, :project_id)
    end
end