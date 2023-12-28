class EmployeesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:toggle_and_save_status, :reset_pin, :send_sms_with_new_pin, :destroy]
  skip_before_action :authenticate_user!, only: [:toggle_and_save_status, :reset_pin, :send_sms_with_new_pin, :destroy]
  before_action :set_employee, only: %i[ show edit update destroy ]
  before_action :authenticate_user!


  # GET /employees or /employees.json
  def index
    if current_user.admin?
      #@employees = Employee.all
      @employees = Employee.includes(:user).all.paginate(page: params[:page], per_page: 9)
      @users = User.all.includes(:keylockers, employee: :keylocker).paginate(page: params[:page], per_page: 9)
    else
      @employees = Employee.where(user_id: current_user.id).paginate(page: params[:page], per_page: 9)
    end
  end

  # GET /employees/1 or /employees/1.json
  def show
    @employee = Employee.find(params[:id])
  end

  # GET /employees/new
  def new
    @employee = Employee.new
    @employee.workdays.build(dayofweek: []) # Inicialize com uma matriz vazia para aceitar múltiplos dias
  end

  # GET /employees/1/edit
  def edit
  end

  # POST /employees or /employees.json
  def create
    @employee = Employee.new(employee_params)
    @employee.user = current_user  
    @employee.keylockers = current_user.keylockers
    # Gere o PIN automaticamente
    @employee.PIN = generate_unique_pin

    respond_to do |format|
      if @employee.save
        send_sms(@employee.phone, "Seu PIN de acesso: #{@employee.PIN}")
        format.html { redirect_to employee_url(@employee), notice: "Funcionário foi criado com sucesso." }
        format.json { render :show, status: :created, location: @employee }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end


  # PATCH/PUT /employees/1 or /employees/1.json
  def update
    respond_to do |format|
      if @employee.update(employee_params)
        format.html { redirect_to employee_url(@employee), notice: "Funcionário foi atualizado com sucesso." }
        format.json { render :show, status: :ok, location: @employee }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /employees/1 or /employees/1.json
  def destroy
    @employee.destroy

    respond_to do |format|
      format.html { redirect_to employees_url, notice: "Funcionário foi deletado com sucesso." }
      format.json { head :no_content }
    end
  end

  def send_sms(phone, message)
    api_key = "05LleS23oQMPDXClXuLl"       
    # Adicionando os parâmetros diretamente na URL
    url = "https://sistema81.smsbarato.com.br/send?chave=#{CGI.escape(api_key)}&dest=#{CGI.escape(phone)}&text=#{CGI.escape(message)}"

    puts "Fazendo solicitação POST para: #{url}"
    begin
      # Fazendo a solicitação GET
      response = RestClient.post(url, {})
      puts "Resposta do servidor: #{response.body}"
      puts "Código de status: #{response.code}"
    rescue RestClient::ExceptionWithResponse => e
      puts "Erro na solicitação: #{e.response.body}"
      puts "Código de status: #{e.response.code}"
    end
  end

  def reset_pin
    @employee = Employee.find(params[:id]) # Certifique-se de encontrar a instância correta pelo ID
    if @employee
      @employee.PIN = generate_unique_pin
      if @employee.save
        send_sms_with_new_pin(params[:phone], @employee.PIN)
        render json: { message: 'Novo PIN resetado e enviado por SMS com sucesso!' }
      else
        render json: { error: 'Erro ao resetar o novo PIN.' }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Funcionário não encontrado.' }, status: :not_found
    end
  end
 
  def toggle_and_save_status
    @employee = Employee.find(params[:id])
    @employee.update(status: (@employee.status == 'bloqueado' ? 'desbloqueado' : 'bloqueado'))
    respond_to do |format|
      format.json { render json: { status: @employee.status } }
    end
  end

  
  private

    def generate_unique_pin
      loop do
        pin = generate_pin
        return pin unless Employee.exists?(PIN: pin)
      end
    end

    def generate_pin
      # Lógica para gerar um PIN único
      # Aqui está um exemplo simples, você pode ajustar conforme necessário
      characters = ('0'..'9').to_a + ('A'..'D').to_a
      pin = (0...6).map { characters.sample }.join
    end

    def send_sms_with_new_pin(phone, pin)
      api_key = '05LleS23oQMPDXClXuLl' # Substitua pela sua chave de API
      puts "Telefone: #{phone}"
      puts "Seu novo PIN é: #{pin}"
      message = "Seu novo PIN é: #{pin}"
      url = "https://sistema81.smsbarato.com.br/send?chave=#{CGI.escape(api_key)}&dest=#{CGI.escape(phone)}&text=#{CGI.escape(message)}"  
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_employee
      @employee = Employee.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def employee_params
      params.require(:employee).permit(
        :name, :lastname, :companyID, :phone, :PIN, :function, :pswdSmartlocker, :cardRFID, :status, :profile_picture,
        workdays_attributes: [:id, { dayofweek: [] }, :start, :end, :holiday, :_destroy]
      )
    end
end
