class AddressesController < ApplicationController
    def new
      @address = Address.new
    end
  
    def create
      @address = Address.new(address_params)
      if @address.save
        # Lógica de redirecionamento ou renderização
      else
        render :new
      end
    end
  
    # Outras ações conforme necessário: edit, update, destroy, etc.
  
    private
  
    def address_params
      params.require(:address).permit(:zip_code, :street, :city, :state)
    end
end
  