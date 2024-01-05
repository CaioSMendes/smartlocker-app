class Employee < ApplicationRecord
    before_create :set_default_status
    has_many :workdays, dependent: :destroy
    belongs_to :user
    has_and_belongs_to_many :keylockers
  
    has_many :employees_keylockers
    has_one_attached :profile_picture
  
    accepts_nested_attributes_for :workdays, reject_if: :all_blank, allow_destroy: true
  
    private
  
    def set_default_status
      self.status ||= 'debloqueado'
    end
  end
  