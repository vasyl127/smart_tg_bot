class User < ApplicationRecord
  after_create :create_user_config

  has_one :config, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :user_categories, dependent: :destroy
  has_many :categories, through: :user_categories
  has_many :random_values, dependent: :destroy
  has_many :notifications, dependent: :destroy

  def create_user_config
    Config.create(user_id: self.id)
  end
end
