class Post < ActiveRecord::Base
  attr_accessible :body, :title, :group_ids
  has_many :groups, :through => :post_group_associations
  has_many :post_group_associations
  accepts_nested_attributes_for :groups, :allow_destroy => true
  after_create :send_mailing

  def self.public
    joins(:groups).where("groups.name = ?", "public")
  end

  def self.viewable_by_announcee(announcee)
    groups = announcee.groups
    joins(:groups).where("groups.id IN (?) OR groups.name = ?", groups.map{|group| group.id}, "public").uniq
  end
  
  private
  def send_mailing
    PostMailer.new_post(self).deliver
  end
end