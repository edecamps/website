class Image < ActiveRecord::Base
  attr_accessible :alt, :artwork
  mount_uploader :artwork, ImageUploader
end
