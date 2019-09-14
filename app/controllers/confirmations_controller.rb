class ConfirmationsController < Milia::ConfirmationsController
  def update
    if @confirmable.attempt_set_password(user_params)

      # このセクションは、devise 3.2.5 confirms_controller＃showからパターン化されています

      self.resource = resource_class.confirm_by_token(params[:confirmation_token])
      yield resource if block_given?

      if resource.errors.empty?
        log_action( "確認済みの招待者" )
        set_flash_message(:notice, :confirmed) if is_flashing_format?
          # 自動的にログイン
        sign_in_tenanted_and_redirect(resource)
        
      else
        log_action( "招待者の確認に失敗しました" )
        respond_with_navigational(resource.errors, :status => :unprocessable_entity){ render :new }
      end

    else
      log_action( "招待者のパスワード設定に失敗しました" )
      prep_do_show()  # prep for the form
      respond_with_navigational(resource.errors, :status => :unprocessable_entity){ render :show }
    end  # if..then..else passwords are valid
  end
  
  def show
    if @confirmable.new_record?  ||
       !::Milia.use_invite_member || 
       @confirmable.skip_confirm_change_password

      log_action( "パススルーを考案する" )
      self.resource = resource_class.confirm_by_token(params[:confirmation_token])
      yield resource if block_given?
      
      if resource.errors.empty?
        set_flash_message(:notice, :confirmed) if is_flashing_format?
      end
      
      if @confirmable.skip_confirm_change_password
        sign_in_tenanted_and_redirect(resource)
      end
    else
      log_action( "パスワード設定フォーム" )
      flash[:notice] = "パスワードを選択して確認してください"
      prep_do_show()  # フォームの準備
    end
    # それ以外の場合は、SUBMITでパスワードを設定するためのフォームである
    # テンプレートが表示され、更新から処理が続行されます
  end
  
  def after_confirmation_path_for(resource_name, resource)
    if user_signed_in?
      root_path
    else
      new_user_session_path
    end
  end
  
  private
  
    def set_confirmable()
      @confirmable = User.find_or_initialize_with_error_by(:confirmation_token, params[:confirmation_token])
    end
end
