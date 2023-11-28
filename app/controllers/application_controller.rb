class ApplicationController < ActionController::Base
    before_action :authenticate_user!
    before_action :configure_permitted_parameters, if: :devise_controller?

    protected

    def configure_permitted_parameters
        devise_parameter_sanitizer.permit(
            :sign_up, keys: [
            :phone, :name, :lastname, :cnpj, :nameCompany, address_attributes: 
                [
                    :street, :city, :state, :zip_code
                ]
            ])
        devise_parameter_sanitizer.permit(
            :account_update, keys: [
                :phone, :name, :lastname, :cnpj, :nameCompany, address_attributes: 
                [
                    :street, :city, :state, :zip_code
                ]
            ]
        )
      end
end


 
