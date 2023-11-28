I18n.locale = :pt

module Api
  module V1
    class EmployeesController < ApplicationController
      skip_before_action :verify_authenticity_token, only: [:esp8288params, :check_user, :count_and_track_spaces, :outro_metodo]
      skip_before_action :authenticate_user!, only: [:esp8288params, :check_user, :count_and_track_spaces, :outro_metodo]

      def index
        @employees = Employee.all
        render json: @employees
      end

      def esp8288params
        id_nv_usr = params[:ID_NV_USR]
        rfid_nv_usr = params[:RFID_NV_USR]
        snh_nv_usr = params[:SNH_NV_USR]
    
        # Encontre o funcionário com base no campo PIN
        employee = Employee.find_by(PIN: id_nv_usr)
    
        if employee
          # Atualize o campo cardRFID se RFID_NV_USR estiver presente
          employee.update(cardRFID: rfid_nv_usr) if rfid_nv_usr.present?
    
          # Atualize os campos pswdSmartlocker se SNH_NV_USR estiver presente
          if snh_nv_usr.present?
            employee.update(pswdSmartlocker: snh_nv_usr)
            render json: { message: 'Usuário cadastrado com sucesso' }
          else
            render json: { message: 'SNH_NV_USR é obrigatório' }, status: :unprocessable_entity
          end
        else
          render json: { message: 'ID_NV_USR não corresponde a nenhum PIN de funcionário' }, status: :unprocessable_entity
        end
      end

      def check_user
        employee_info = nil
        snh_keypad_usr = params[:SNH_KEYPAD_USR]
        card_rfid = params[:CARD_RFID]
      
        if snh_keypad_usr.present?
          employee = Employee.find_by(pswdSmartlocker: snh_keypad_usr)
        elsif card_rfid.present?
          employee = Employee.find_by(cardRFID: card_rfid)
        end


        workdays = employee.workdays

        current_day = I18n.l(Time.now, format: '%A').capitalize
        puts "Current day: #{current_day.inspect}"

        today_workday = workdays.find { |wd| wd.dayofweek&.include?(current_day) }
        puts "Today Workday: #{today_workday.inspect}"

        if today_workday.present? && today_workday.dayofweek.present?
          today_workday_start = Time.parse(today_workday&.start.strftime('%H:%M:%S')) # Formata o início para o formato correto
          today_workday_end = Time.parse(today_workday&.end.strftime('%H:%M:%S'))     # Formata o fim para o formato correto

          puts "Today Workday Start: #{today_workday_start.inspect}"
          puts "Today Workday End: #{today_workday_end.inspect}"

          current_time = Time.now
          puts "Current Time: #{current_time}"

          if current_time.between?(today_workday_start, today_workday_end)
            @employee_info = {
              name: employee.name,
              lastname: employee.lastname,
              datetime: Time.now.strftime('%Y-%m-%d %H:%M:%S'),
              keylockers: employee.keylockers.map do |keylocker|
                {
                  keylocker_name: keylocker.nameDevice,
                  keylocker_status: keylocker.status
                }
              end
            }
            session[:employee_info] = @employee_info
            render json: @employee_info
          else
            render json: { message: 'Funcionário fora do horário de serviço.' }
          end
        else
          render json: { message: 'Não é o dia de trabalho desse funcionário' }
        end
      end
      

      def count_and_track_spaces
        @employee_info = session[:employee_info] 
        binary_sequence = params[:binary_sequence]
      
        if binary_sequence.present?
          positions = binary_sequence.chars.each_with_index.select { |value, index| value == '0' }.map { |_, index| index + 1 }
          positionskey = binary_sequence.chars.each_with_index.select { |value, index| value == '0' }.map(&:last)
          register_positions(positions)
      
          positions_text = positions.map { |position| "chave #{position}" }.join(' e ')
          puts "Employee Info before render: #{@employee_info}"
      
          render json: {
            #positions_key: positionskey,
            employee_info: @employee_info,
            message: "#{positions_text} estão fora"
          }

          log_data = {
            employee_info: @employee_info,
            message: "#{positions_text} estão fora"
          }
        else
          render json: { message: 'Sequência binária não fornecida' }, status: :unprocessable_entity
        end
        Log.create(log_data)
      end
      
      def outro_metodo
        @employee_info = session[:employee_info]  # Recupera de sessão
        # Agora você pode acessar @employee_info aqui
        puts "Employee Info em outro_metodo: #{@employee_info.inspect}" if @employee_info.present?
        render json: @employee_info.to_json if @employee_info.present?
      end
    
      
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

      def belongs_to_keylocker
        @employee = Employee.find(params[:employee_id])
        @keylocker = Keylocker.find(params[:keylocker_id])
    
        authorize @employee # Certifique-se de adicionar isso se estiver usando Pundit ou outra gem de autorização
    
        belongs_to_keylocker = @employee.keylockers.include?(@keylocker)
    
        render json: { belongs_to_keylocker: belongs_to_keylocker }
      end

      private
      # Use callbacks to share common setup or constraints between actions.
      def set_employee
        @employee = Employee.find(params[:id])
      end

      def register_positions(positions)
        positions.each do |position|
          Keylog.create(position: position, status: 'ocupada')
        end
      end

      # Only allow a list of trusted parameters through.
      def employee_params
        params.require(:employee).permit(
          :pswdSmartlocker, :cardRFID
        )
      end

      def allow_cors
        # Configuração para permitir solicitações de origens diferentes (CORS)
        response.headers['Access-Control-Allow-Origin'] = '*'
        response.headers['Access-Control-Allow-Methods'] = 'POST, PUT, PATCH, GET, OPTIONS'
        response.headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
      end

    end
  end
end