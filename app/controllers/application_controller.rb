class ApplicationController < ActionController::Base
  before_action :authenticate_tenant!
  protect_from_forgery with: :exception
  before_action :authenticate_tenant!
  
     # miliaはデフォルトのmax_tenants、invalid_tenant例外処理を定義します
     # ただし、直接処理する場合はこれらをオーバーライドできます
  rescue_from ::Milia::Control::MaxTenantExceeded, :with => :max_tenants
  rescue_from ::Milia::Control::InvalidTenantAccess, :with => :invalid_tenant
  
  def logged_in?
    !!current_user
  end

end
