require 'digi_fi'

namespace :messages do
  desc "send the last x messages without "
  task :send => :environment do
    digi_fi = DigiFi.new
    message = Message.where(job_id:nil).last(1)
    if job_id = digi_fi.send_message(message)
      message.update_column(:job_id, job_id)
    end
  end
end
