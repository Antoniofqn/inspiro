require 'openai'

OpenAI.configure do |config|
  config.access_token = ENV['GPT_SECRET_KEY']
  config.log_errors = true
end
