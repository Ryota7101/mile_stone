class RegistrationsController < Milia::RegistrationsController
  #ユーザー登録機能

  skip_before_action :authenticate_tenant!, :only => [:new, :create, :cancel]

  def create
      # テナントコールバックが変更を加える場合に備えて、
      # パラメーターの作業用コピーを用意します
    tenant_params = sign_up_params_tenant
    user_params   = sign_up_params_user.merge({ is_admin: true })
    coupon_params = sign_up_params_coupon

    sign_out_session!
       # 次の2行は、サインアップビューのパラメーターを準備します
    prep_signup_view( tenant_params, user_params, coupon_params )

       # 有効になっていない限り、最初にrecaptchaを検証します
    if !::Milia.use_recaptcha  ||  verify_recaptcha

      Tenant.transaction  do 
        @tenant = Tenant.create_new_tenant( tenant_params, user_params, coupon_params)
        if @tenant.errors.empty?   # tenant created
          if @tenant.plan == 'premium'
            @payment = Payment.new({ email: user_params["email"],
              token: params[:payment]["token"],
              tenant: @tenant })
            flash[:error] = "登録エラーを確認してください" unless @payment.valid?
            
            begin
              @payment.process_payment
              @payment.save
            rescue Exception => e 
              flash[:error] = e.message
              @tenant.destroy
              log_action("支払いに失敗しました")
              render :new and return
            end
          end
        else
          resource.valid?
          log_action( "テナント作成に失敗しました", @tenant )
          render :new
        end # if .. then .. else no tenant errors
        
        if flash[:error].blank? || flash[:error].empty? #支払い完了
          initiate_tenant( @tenant )    # 新しいテナント向けの初めてのもの

          devise_create( user_params )   # リソース（ユーザー）作成を考案し、リソースを設定します

          if resource.errors.empty?   #  SUCCESS!

            log_action( "signup user/tenant success", resource )
              # 必要なテナントの初期設定を行います
            Tenant.tenant_signup(resource, @tenant, coupon_params)

          else  # ユーザーの作成に失敗しました。 テナントのロールバックを強制する
            log_action( "signup user create failed", resource )
            raise ActiveRecord::Rollback   # テナントトランザクションを強制的にロールバックする
          end  # if..then..else for valid user creation
        else
          resource.valid?
          log_action("Payment processing failed", @tenant )
          render :new and return
        end # if.. then .. else no tenant errors
      end  #  トランザクションでテナント/ユーザー作成をラップする
    else
      flash[:error] = "Recaptcha codes didn't match; please try again"
         # sign_upフォームが再レンダリングされると、すべての検証エラーが渡されます
      resource.valid?
      @tenant.valid?
      log_action( "recaptcha failed", resource )
      render :new
    end

  end   # def create

  # ------------------------------------------------------------------------------
  # ------------------------------------------------------------------------------

    protected

  # ------------------------------------------------------------------------------
  # ------------------------------------------------------------------------------
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up) + ::Milia.whitelist_user_params
    end

  # ------------------------------------------------------------------------------
  # ------------------------------------------------------------------------------
    def sign_up_params_tenant()
      params.require(:tenant).permit( ::Milia.whitelist_tenant_params )
    end

  # ------------------------------------------------------------------------------
  # ------------------------------------------------------------------------------
    def sign_up_params_user()
      params.require(:user).permit( ::Milia.whitelist_user_params )
    end

  # ------------------------------------------------------------------------------
  # sign_up_params_coupon -- permit coupon parameter if used; else params
  # ------------------------------------------------------------------------------
    def sign_up_params_coupon()
      ( ::Milia.use_coupon ? 
        params.require(:coupon).permit( ::Milia.whitelist_coupon_params )  :
        params
      )
    end

  # ------------------------------------------------------------------------------
  # sign_out_session! -- force the devise session signout
  # ------------------------------------------------------------------------------
    def sign_out_session!()
      Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name) if user_signed_in?
    end

  # ------------------------------------------------------------------------------
  # devise_create -- duplicate of Devise::RegistrationsController
      # same as in devise gem EXCEPT need to prep signup form variables
  # ------------------------------------------------------------------------------
    def devise_create( user_params )

      build_resource(user_params)

        # if we're using milia's invite_member helpers
      if ::Milia.use_invite_member
          # then flag for our confirmable that we won't need to set up a password
        resource.skip_confirm_change_password  = true
      end

      if resource.save
        yield resource if block_given?
        log_action( "devise: signup user success", resource )
        if resource.active_for_authentication?
          set_flash_message :notice, :signed_up if is_flashing_format?
          sign_up(resource_name, resource)
          respond_with resource, :location => after_sign_up_path_for(resource)
        else
          set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
          expire_data_after_sign_in!
          respond_with resource, :location => after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords resource
        log_action( "devise: signup user failure", resource )
        prep_signup_view(  @tenant, resource, params[:coupon] )   
        respond_with resource
      end
    end

  # ------------------------------------------------------------------------------
  # ------------------------------------------------------------------------------
    def after_sign_up_path_for(resource)
      headers['refresh'] = "0;url=#{root_path}"
      root_path
    end

  # ------------------------------------------------------------------------------
  # ------------------------------------------------------------------------------
    def after_inactive_sign_up_path_for(resource)
      headers['refresh'] = "0;url=#{root_path}"
      root_path
    end
  # ------------------------------------------------------------------------------
  # ------------------------------------------------------------------------------

    def log_action( action, resource=nil )
      err_msg = ( resource.nil? ? '' : resource.errors.full_messages.uniq.join(", ") )
      logger.debug(
        "MILIA >>>>> [register user/org] #{action} - #{err_msg}"
      ) unless logger.nil?
    end

  # ------------------------------------------------------------------------------
  # ------------------------------------------------------------------------------

  # ------------------------------------------------------------------------------
  # ------------------------------------------------------------------------------

end   # class Registrations