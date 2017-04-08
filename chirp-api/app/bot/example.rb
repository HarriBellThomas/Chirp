# app/bot/example.rb

include Facebook::Messenger


Bot.on :message do |message|
  message.reply(text: 'Hello, human!')
end
