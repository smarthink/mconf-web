# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe UserApprovedSenderWorker do
  let(:worker) { UserApprovedSenderWorker }

  before {
    Site.current.update_attributes(require_registration_approval: true)
  }

  it "uses the queue :user_notifications" do
    worker.instance_variable_get(:@queue).should eql(:user_notifications)
  end

  describe "#perform" do
    let(:user) { FactoryGirl.create(:user, approved_notification_sent_at: nil) }
    before { user.reload.approved_notification_sent_at.should be_nil }

    before(:each) { worker.perform(user.id) }

    it { AdminMailer.should have_queue_size_of_at_least(1) }
    it { AdminMailer.should have_queued(:new_user_approved, user.id).in(:mailer) }
    it { user.reload.approved_notification_sent_at.should_not be_nil }
  end

end
