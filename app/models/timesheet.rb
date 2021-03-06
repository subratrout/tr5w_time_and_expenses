class Timesheet < ApplicationRecord
  belongs_to :approver,
             -> { where('authorized_approver = ?', true).extending(CheckApproverExtension) },
             :class_name => 'User',
             :foreign_key => 'approver_id'

  belongs_to :user, :validate => true

  has_many :billable_weeks, -> { includes(:billing_code) }

  scope :draft, -> { where(:submitted => false) }
  scope :latest, -> { order('created_at desc').limit(1) }

  def self.billable_hours_outstanding_for(user)
    user.timesheets.map(&:billable_hours_outstanding).sum
  end

  def billable_hours_outstanding
    submitted? ? billable_weeks.map(&:total_hours).sum : 0
  end
end

class UnauthorizedApproverException < Exception
end
