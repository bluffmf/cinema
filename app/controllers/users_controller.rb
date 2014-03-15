# -*- encoding : utf-8 -*-
class UsersController < ApplicationController
  before_filter :authenticate, :only => [:edit, :update]

  
  def index
    @users = User.all
  end

  def new
  	@user = User.new
  end

  def create
  	@user = User.new(user_params)

  	if @user.save
  	  flash[:success] = "Добро пожаловать #{@user.name}!"
  	  redirect_to @user
  	else
  	  render 'new'
  	end
  end

  def show
  	@user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
    @title = "Edit user"
  end

  def update 
    @user = User.find(params[:id])

    if @user.update_attributes(user_params)
      flash[:success] = "Профиль обновлён."
      redirect_to @user
    else
      @title = "Edit user"
      render 'edit'
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    def authenticate
      deny_access unless signed_id?
    end
end
