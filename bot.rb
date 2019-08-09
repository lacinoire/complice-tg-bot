require 'rubygems'

require 'httparty'
require 'logger'
require 'telegram/bot'
require 'pp'

load 'config.rb'
load 'complice/complice.rb'

def split_command_botname(command)
  splitter_index = command.index('@') || command.length
  raw_command = command[0, splitter_index]
  bot_name = command[splitter_index + 1, command.length]
  [raw_command, bot_name]
end

if $PROGRAM_NAME == __FILE__

  Telegram::Bot::Client.run(Config.config['bot']['token'], logger: Logger.new($stderr)) do |bot|
    bot.logger.info('Bot has been started')
    bot.listen do |message|

      # ignore if message is not from you
      next if message.from.id != Config.config['user']['tg_id']

      command_data = message.entities.find { |entity| entity.type == 'bot_command'}
      if command_data.offset != 0
        bot.api.send_message(chat_id: message.chat.id, text: 'Please give bot command first in your message :)')
        next
      end

      long_command = message.text[0, command_data.length]
      command, bot_name = split_command_botname(long_command)

      text = message.text[command_data.length + 1, message.text.length]

      if !bot_name.nil? && bot_name != Config.config['bot']['username']
        # ignore message cause it was adressed to another bot
        next
      end

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
        if response == 'wrong intention format'
          bot.api.send_message(chat_id: message.chat.id, text: "Please use the intention format to add intentions!")
        else
          bot.api.send_message(chat_id: message.chat.id, text: "You now have #{response} intentions for /today")
        end
      when '/complete'
        successful = Complice.complete(text)
        if successful
          bot.api.send_message(chat_id: message.chat.id, text: "Item #{text} completed!")
        else
          bot.api.send_message(chat_id: message.chat.id, text: "Please give a valid zid to complete!")
        end
      else
        bot.api.send_message(chat_id: message.chat.id, text: "I don't understand you :(")
      end
    end
  end

end
