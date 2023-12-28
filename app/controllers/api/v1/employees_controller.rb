I18n.locale = :pt

module Api
  module V1
    class EmployeesController < ApplicationController
      skip_before_action :verify_authenticity_token, only: [:esp8288params, :check_user, :count_and_track_spaces, :outro_metodo, :key_locker_history]
      skip_before_action :authenticate_user!, only: [:esp8288params, :check_user, :count_and_track_spaces, :outro_metodo, :key_locker_history]
      before_action :initialize_positions_text

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
        else
          # Nenhum método de autenticação fornecido ou nenhum funcionário encontrado
          render json: { message: 'Método de autenticação não fornecido ou funcionário não encontrado.' }
          return  # Adiciona um retorno para sair da ação
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
              user_status: employee.status,
              datetime: Time.now.strftime('%Y-%m-%d %H:%M:%S'),
              keylockers: employee.keylockers.map do |keylocker|
                {
                  keylocker_owner: keylocker.owner,
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
        @binary_sequence = params[:binary_sequence]

        if binary_sequence.present?
          result = {}
          positions = binary_sequence.chars.each_with_index.select { |value, index| value == '0' }.map { |_, index| index + 1 }
          register_positions(positions)
          positions_keys = positions.map { |position| "chave #{position}" }.join(' e ')

          #session[:binary_sequence_before] = @binary_sequence #zera o session
          puts "Sequencia salva na Session: #{session[:binary_sequence_before]}"
          vetor_anterior = session[:binary_sequence_before].chars.map(&:to_i)
          puts "Sequencia Recebida #{@binary_sequence}"
          vetor_atual = @binary_sequence.chars.map(&:to_i)

          alteracoes = vetor_atual.each_with_index.select do |value, index|
            puts "Iteration: index=#{index + 1}, salvoSessao=#{vetor_anterior[index]}, valorAtual=#{value}"
            value != vetor_anterior[index]
          end

          alteracoes.each do |value, index|
            puts "Elemento na posição #{index} mudou de #{vetor_anterior[index]} para #{vetor_atual[index]}"
          end

          posicoes_alteradas = alteracoes.map { |value, index| index + 1 }
          puts "Posições alteradas: #{posicoes_alteradas}"


          render json: {
          employee_info: @employee_info,
          chaves_ocupadas: positions_keys,
          chaves_devolvidas: posicoes_alteradas
        }

        log_data = {
          employee_info: @employee_info,
        }
      
          # Adicionar informações ao log apenas se a sequência binária estiver presente
          Log.create(log_data) if binary_sequence.present?
        else
          render json: { message: 'Sequência binária não fornecida' }, status: :unprocessable_entity
        end
      end

      def key_locker_history
        @employee_info = session[:employee_info] 
        owner = params[:owner]
        name_device = params[:nameDevice]
        binary_sequence = params[:binarySequence]


        lockerOwner = Keylocker.find_by(owner: owner)
        puts "lockerOwner: #{lockerOwner.inspect}"

        lockerDevice = Keylocker.find_by(nameDevice: name_device)
        puts "lockerDevice: #{lockerDevice.inspect}"
      
        if lockerOwner.present? && lockerDevice.present? 
          keys_in_place = []
          keys_out_of_place = []
          last_changed_position = nil

          binary_sequence.chars.each_with_index do |value, index|
            if value == '1'
              keys_in_place << index + 1 # Adiciona 1 para começar a contar da posição 1
            elsif value == '0'
              keys_out_of_place << index + 1
            end
          end

          keys_in_place_text = "Chaves livres: #{keys_in_place.join(', ')}"
          keys_out_of_place_text = "Chaves ocupadas: #{keys_out_of_place.join(', ')}"
          
          render json: {
            proprietario: owner,
            device: name_device,
            informação: @employee_info,
            todas_chaves: binary_sequence,
            chaves_livres: keys_in_place_text,
            chaves_ocupadas: keys_out_of_place_text,
            created_at: Time.now
          }

          puts "Chaves Vetor: #{binary_sequence.inspect}"

          history_entry = {
            owner: owner,
            name_device: name_device,
            employee_info: @employee_info,
            keys_taken: keys_in_place_text,
            keys_returned: keys_out_of_place_text,
            sequence_order: binary_sequence.chars.map(&:to_i),
            created_at: Time.now
          }
          puts "history_entry: #{history_entry.inspect}"
          HistoryEntry.create(history_entry)if binary_sequence.present?
          puts "historico criado e salvo"
        else
          render json: { error: 'Proprietário ou nome do dispositivo inválido' }, status: :unprocessable_entity
        end
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

      def set_employee
        @employee = Employee.find(params[:id])
      end

      def initialize_key_status
        @key_status = Hash.new { |hash, key| hash[key] = { status: :available, returned: false } }
      end

      def parse_returned_keys(returned_keys_param)
        return [] unless returned_keys_param.present?
        returned_keys_param.split(',').map(&:to_i)
      end

      def initialize_positions_text
        @positions_text = Hash.new(0)
        session[:counter] ||= {}
      end

      def increment_positions_text
        @positions_text.transform_values! { |value| value + 1 }

        # Garante que session[:counter] seja sempre um hash
        session[:counter] ||= {}
        session[:counter] = (session[:counter].is_a?(Hash) ? session[:counter] : {}).transform_values! { |value| value.to_i + 1 }
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