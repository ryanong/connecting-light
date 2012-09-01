require 'digi_fi'

namespace :messages do
  desc "send the last x messages without "
  task :send => :environment do
    digi_fi = DigiFi.new
    if messages = Message.where(job_id:nil).last(1)
      messages.each do |message|
        if job_id = digi_fi.send_message(message)
          message.update_column(:job_id, job_id)
        end
      end
    end
  end
end
