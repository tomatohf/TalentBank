class JobPhoto < ActiveRecord::Base
  
  belongs_to :student, :class_name => "Student", :foreign_key => "student_id"
  
  
  validates_presence_of :student_id
  
  
  Normal_W = 90
  Normal_H = 110
  Large_W = 400
  Large_H = 400
  
  # paperclip
  has_attached_file(
    :image,
    :styles => {
      :large => "#{Large_W}x#{Large_H}>",
      :normal => {
        :processors => [:jcropper],
        :geometry => "#{Normal_W}x#{Normal_H}#"
      },
      :cropped => {
        :processors => [:jcropper],
        :geometry => "",  # only crop without resize
        :format => :jpg   # PDF lib prawn only support JPG and PNG currently
      }
    },
    :path => ":rails_root/public/system/files/:class_:attachment/:created_year/:created_month/:created_mday/:id/:style_:id.:extension",
    :url => "/system/files/:class_:attachment/:created_year/:created_month/:created_mday/:id/:style_:id.:extension",
    :default_url => "",
    :storage => :filesystem,
    :whiny_thumbnails => false # to avoid displaying internal errors
  )

  validates_attachment_presence :image, :message => "请选择 照片"
  validates_attachment_content_type :image, :content_type => [
    "image/jpg", "image/jpeg", "image/gif", "image/png", "image/bmp",
    
    # to be compatible with IE ...
    "image/pjpeg", "image/x-png"
  ], :message => "只能上传 JPG, JPEG, GIF, PNG 或 BMP 格式的照片"
  validates_attachment_size :image, :less_than => 3.megabyte, :message => "每个照片文件大小不能超过 3M"
  # to avoid displaying internal errors
  # validates_attachment_thumbnails :image
  
  
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h

  after_update :reprocess_image, :if => :crop?
  
  after_save { |job_photo|
    job_photo.clear_resume_html_fragment_cache
  }
  
  after_destroy { |job_photo|
    job_photo.clear_resume_html_fragment_cache
  }


  def clear_resume_html_fragment_cache
    Resume.find(
      :all,
      :conditions => ["student_id = ?", self.student_id]
    ).each do |resume|
      resume.clear_html_fragment_cache
    end
  end
  
  
  def crop?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  # helper method used by the cropper view to get the real image geometry
  def image_geometry(style = :original)
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(image.path(style))
  end
  
  
  Belongs_To_Keys = [:student_id]
  include Utils::UniqueBelongs


  private

  def reprocess_image
    image.reprocess!
  end
  
end
