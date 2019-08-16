class CategoriesController < ApplicationController
  before_action :require_admin, except: [:index, :show]

  def index
    @categories = Category.paginate(page: params[:page], per_page: 5)
  end
  
  def new
    @category = Category.new
    @category.project_id = params[:project_id]
  end
  
  def show
    @category = Category.find(params[:id])
    @category_tasks = @category.tasks.paginate(page: params[:page], per_page: 5)
  end
  
  def create
      @category = Category.new(category_params)
    
      if @category.save
        flash[:success] = "カテゴリを作成しました"
        redirect_to categories_path
      else
        render 'new'
      end
  end
  
  def edit
    @category = Category.find(params[:id])
  end

  def update
    @category = Category.find(params[:id])
    if @category.update(category_params)
      flash[:success] = "カテゴリ名を更新しました"
      redirect_to category_path(@category)
    else
      render 'edit'
    end
  end
  
  private

    def category_params
      params.require(:category).permit(:name, :project_id)
    end
    
    def require_admin
      if !logged_in? || (logged_in? and !current_user.is_admin?)
        flash[:danger] = "管理者のみがアクセスできます"
        redirect_to categories_path
      end
    end
end
