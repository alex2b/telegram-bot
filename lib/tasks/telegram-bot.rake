# frozen_string_literal: true

namespace :telegram do
  namespace :bot do
    desc 'Run poller. It broadcasts Rails.logger to STDOUT in dev like `rails s` do. ' \
      'Use LOG_TO_STDOUT to enable/disable broadcasting.'
    task :poller, [:all_updates] do |t, args|
      args.with_defaults(all_updates: nil)
      allowed_updates = Telegram::Bot::UpdatesController::PAYLOAD_TYPES if args[:all_updates]

      ENV['BOT_POLLER_MODE'] = 'true'
      Rake::Task['environment'].invoke
      if ENV.fetch('LOG_TO_STDOUT') { Rails.env.development? }.present?
        console = ActiveSupport::Logger.new($stderr)
        if Rails.logger.respond_to?(:broadcast_to)
          Rails.logger.broadcast_to(console)
        else
          Rails.logger.extend ActiveSupport::Logger.broadcast console
        end
      end
      Telegram::Bot::UpdatesPoller.start(ENV['BOT']&.to_sym || :default, nil, allowed_updates: allowed_updates)
    end

    desc 'Set webhook urls for all bots'
    task :set_webhook, [:all] => :environment do |_, args|
      args.with_defaults(all_updates: nil)
      allowed_updates = Telegram::Bot::UpdatesController::PAYLOAD_TYPES if args[:all_updates]

      Telegram::Bot::Tasks.set_webhook(allowed_updates: allowed_updates)
    end

    desc 'Delete webhooks for all or specific BOT'
    task :delete_webhook do
      Telegram::Bot::Tasks.delete_webhook
    end

    desc 'Perform logOut command for all or specific BOT'
    task :log_out do
      Telegram::Bot::Tasks.log_out
    end

    desc 'Perform `close` command for all or specific BOT'
    task :close do
      Telegram::Bot::Tasks.close
    end
  end
end
