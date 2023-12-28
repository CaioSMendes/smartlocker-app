# app/controllers/history_entries_controller.rb
class HistoryEntriesController < ApplicationController
    before_action :set_history_entry, only: [:show, :edit, :update, :destroy]
  
    def index
      @history_entries = HistoryEntry.paginate(page: params[:page], per_page: 10)
    end
  
    def show
    end
  
    def new
      @history_entry = HistoryEntry.new
    end
  
    def create
      history_entry_params = params.require(:history_entry).permit(:owner, :name_device, :employee_info, :keys_taken, :keys_returned, :sequence_order, :datahistory)
      @history_entry = HistoryEntry.new(history_entry_params)
  
      if @history_entry.save
        redirect_to @history_entry, notice: 'History entry was successfully created.'
      else
        render :new
      end
    end
  
    def edit
    end
  
    def update
      if @history_entry.update(history_entry_params)
        redirect_to @history_entry, notice: 'History entry was successfully updated.'
      else
        render :edit
      end
    end
  
    def destroy
        @history_entry = HistoryEntry.find(params[:id])
        @history_entry.destroy
        redirect_to history_entries_path, notice: 'History entry was successfully destroyed.'
    end
  
    private
  
    def set_history_entry
      @history_entry = HistoryEntry.find(params[:id])
    end
  
    def history_entry_params
      params.require(:history_entry).permit(:owner, :name_device, :employee_info, :keys_taken, :keys_returned, :sequence_order, :datahistory)
    end
  end  