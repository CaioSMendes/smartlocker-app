class Keylocker < ApplicationRecord
    validates_uniqueness_of :owner, scope: [:nameDevice, :ipAddress, :status]
    has_many :user_lockers
    has_many :users, through: :user_lockers

    has_many :employees_keylockers
    has_and_belongs_to_many :employees

end
