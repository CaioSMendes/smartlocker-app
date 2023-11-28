class HistoricosController < ApplicationController
    def index
        @historicos = Log.all
    end
end
