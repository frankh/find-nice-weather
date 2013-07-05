class Town < ActiveRecord::Base
  has_many :weather, :dependent => :destroy
end
