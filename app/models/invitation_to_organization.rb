class InvitationToOrganization < Invitation
  belongs_to :member, inverse_of: :created_invitations, foreign_key: :invited_by_id
  belongs_to :organization, inverse_of: :invitations
  has_many :notifications, as: :notificator

  validates :invited_by_id, :role, presence: true
  validate :role_inclusion
  validate :email_uniq

  delegate :organization, to: :member

  after_create :send_invitation
  after_create :week_notification

  enumerize :role, in: [:user, :admin, :owner], default: :user, predicates: true

  def owner
    Member.find(self.invited_by_id).user.to_s
  rescue
    ''
  end

  def accept!(user)
    user_member = Member.find_or_create_by!(user: user, organization_id: member.organization_id)
    user_member.update_attribute(:role, role)
    update_attribute(:accepted, true)
  end

  def send_invitation
    InvitationMailer.new_invitation_to_organization(self).deliver_now
  end

  def congratulation
    "You joined #{member.organization.name}."
  end

  def resend
    InvitationMailer.resend_invitation_to_organization(self).deliver_later
  end

  private

  def role_inclusion
    if invited_by_id
      unless member.available_roles.to_h.values.include?(role)
        errors.add(:role, "Should be in #{member.available_roles.to_h.keys.join(', ')}")
      end
    end
  end

  def email_uniq
    unless organization.invitations.where(email: email).empty?
      errors.add(:email, "An invitation has already been sent")
    end
  end

  def week_notification
    date = 1.week.from_now.beginning_of_day
    notifications.create(kind: :resend_invitation, date: date)
  end
end
