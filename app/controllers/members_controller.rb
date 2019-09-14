class MembersController < ApplicationController
#プロジェクト内にメンバーを招待する機能

  # uncomment to ensure common layout for forms
  # layout  "sign", :only => [:new, :edit, :create]

  def new()
    @member = Member.new()
    @user   = User.new()
  end

  def create()
    @user   = User.new( user_params )

    # ok to create user, member
    if @user.save_and_invite_member() && @user.create_member( member_params )
      flash[:notice] = "新しいメンバーが追加され、招待メールが#{@user.email}に送信されました"
      redirect_to root_path
    else
      flash[:error] = "エラーが発生しました！"
      # フォームを再訪する必要がある場合にのみ使用
      @member = Member.new( member_params ) 
      render :new
    end

  end


  private

  def member_params()
    params.require(:member).permit(:first_name, :last_name)
  end

  def user_params()
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

end
