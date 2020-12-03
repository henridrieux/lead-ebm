class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  # validates :first_name, presence: true
  # validates :last_name, presence: true
  # validates :company_name, presence: true
  has_one_attached :photo
  has_many :subscriptions
  has_many :event_categories, through: :subscriptions

end
