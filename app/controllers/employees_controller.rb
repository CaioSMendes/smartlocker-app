class EmployeesController < ApplicationController
  before_action :set_employee, only: %i[ show edit update destroy ]
  before_action :authenticate_user!


  # GET /employees or /employees.json
  def index
    @employees = Employee.all
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
        format.html { redirect_to employee_url(@employee), notice: "Employee was successfully created." }
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
        format.html { redirect_to employee_url(@employee), notice: "Employee was successfully updated." }
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
      format.html { redirect_to employees_url, notice: "Employee was successfully destroyed." }
      format.json { head :no_content }
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
