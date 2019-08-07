require 'rubygems'

require 'httparty'
require 'logger'
require 'telegram/bot'

load 'config.rb'
load 'complice/complice.rb'

if $PROGRAM_NAME == __FILE__

  Telegram::Bot::Client.run(Config.config['bot']['token'], logger: Logger.new($stderr)) do |bot|
    bot.logger.info('Bot has been started')
    bot.listen do |message|

      command_data = message.entities.find { |entity| entity.type == 'bot_command'}
      if command_data.offset != 0
        bot.api.send_message(chat_id: message.chat.id, text: 'Please give bot command first in your message :)')
        next
      end

      command = message.text[0, command_data.length]
      text = message.text[command_data.length + 1, message.text.length]

      case command
      when '/start'
        bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}")
      when '/stop'
        bot.api.send_message(chat_id: message.chat.id, text: "Bye, #{message.from.first_name}")
      when '/compliceuser'
        response = Complice.userinfo
        bot.api.send_message(chat_id: message.chat.id, text: "#{response}")
      when '/goals'
        response = Complice.goals
        bot.api.send_message(chat_id: message.chat.id, text: "#{response}")
      when '/today'
        response = Complice.today_full
        bot.api.send_message(chat_id: message.chat.id, text: "#{response}")
      when '/intention'
        response = Complice.add_new_intention(text)
        bot.api.send_message(chat_id: message.chat.id, text: "You now have #{response} intentions for /today")
      when '/complete'
        response = Complice.complete(text)
        bot.api.send_message(chat_id: message.chat.id, text: "Item #{text} completed!")
      else
        bot.api.send_message(chat_id: message.chat.id, text: "I don't understand you :(")
      end
    end
  end

end
