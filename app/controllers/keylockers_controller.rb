class KeylockersController < ApplicationController
  before_action :set_keylocker, only: %i[ show edit update destroy ]
  #before_action :authenticate_admin_user! # Certifique-se de ter um método de autenticação de admin

  # GET /keylockers or /keylockers.json
  def index
    @keylockers = Keylocker.all
    @users = User.all
  end

  # GET /keylockers/1 or /keylockers/1.json
  def show
  end

  # GET /keylockers/new
  def new
    @keylocker = Keylocker.new
  end

  # GET /keylockers/1/edit
  def edit
  end

  # POST /keylockers or /keylockers.json
  def create
    @keylocker = Keylocker.new(keylocker_params)

    respond_to do |format|
      if @keylocker.save
        format.html { redirect_to keylocker_url(@keylocker), notice: "Keylocker was successfully created." }
        format.json { render :show, status: :created, location: @keylocker }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @keylocker.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /keylockers/1 or /keylockers/1.json
  def update
    respond_to do |format|
      if @keylocker.update(keylocker_params)
        format.html { redirect_to keylocker_url(@keylocker), notice: "Keylocker was successfully updated." }
        format.json { render :show, status: :ok, location: @keylocker }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @keylocker.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /keylockers/1 or /keylockers/1.json
  def destroy
    @keylocker.destroy

    respond_to do |format|
      format.html { redirect_to keylockers_url, notice: "Keylocker was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def assign_keylocker
    user = User.find(params[:user_id])
    keylocker = Keylocker.find(params[:keylocker_id])
    #user.assign_keylocker(keylocker)
    user.keylockers << keylocker
    redirect_to users_path, notice: 'Locker atribuído com sucesso!'
  end

  def remove_keylocker
    #user_locker = UserLocker.find_by(user_id: params[:user_id], keylocker_id: @keylocker.id)
    #user_locker.destroy if user_locker.present?
    user = User.find(params[:user_id])
    keylocker = Keylocker.find(params[:keylocker_id])
    user.remove_keylocker(keylocker)
    redirect_to users_path, notice: 'Locker removido com sucesso!'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_keylocker
      @keylocker = Keylocker.find(params[:id])
    end

    def authenticate_admin_user!
      # Adicione lógica para verificar se o usuário é um administrador.
      # Você pode usar Devise's current_user ou outra lógica personalizada.
    end

    # Only allow a list of trusted parameters through.
    def keylocker_params
      params.require(:keylocker).permit(:owner, :nameDevice, :ipAddress, :status)
    end
end
