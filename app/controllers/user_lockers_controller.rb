# app/controllers/user_lockers_controller.rb
class UserLockersController < ApplicationController
  before_action :authenticate_admin_user!

  def index
    @users = User.all
    @keylockers = Keylocker.all
  end

  def assign_keylocker
    @user = User.find(params[:user_id])
    keylocker = Keylocker.find(params[:keylocker_id])
    if @user && keylocker
      @user.keylockers << keylocker
      redirect_to keylockers_path, notice: 'Keylocker atribuído ao usuário com sucesso.'
    else
      redirect_to keylockers_path, alert: 'Falha ao atribuir Keylocker ao usuário.'
    end
  end

  def remove_keylocker
    Rails.logger.debug "Entrou na função remove_keylocker!"
    puts"user_id: #{params[:user_id]}, keylocker_id: #{params[:keylocker_id]}"


    @user = User.find(params[:user_id])
    keylocker = Keylocker.find(params[:keylocker_id])

    Rails.logger.debug "user_id: #{params[:user_id]}, keylocker_id: #{params[:keylocker_id]}"
    puts"user_id: #{params[:user_id]}, keylocker_id: #{params[:keylocker_id]}"

    if @user && keylocker
      @user.keylockers.delete(keylocker)
      redirect_to keylockers_path, notice: 'Keylocker removido do usuário com sucesso.'
    else
      redirect_to keylockers_path, alert: 'Falha ao remover Keylocker do usuário.'
    end
  end

  private

  def authenticate_admin_user!
    # Adicione lógica para verificar se o usuário é um administrador.
    # Você pode usar Devise's current_user ou outra lógica personalizada.
  end
end
