class Micropost < ActiveRecord::Base
  belongs_to :user
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validate :picture_size
  default_scope -> { order(created_at: :desc) }
  mount_uploader :picture, PictureUploader

  private 
    def picture_size 
      if picture.size > 5.megabytes
        errors.add(:picture, "must be < 5MB")
      end
    end
end
