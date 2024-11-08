class ResetSearchCountJob
  include Sidekiq::Job
  queue_as :default

  def perform
    User.update_all(search_count: 0)
  end
end