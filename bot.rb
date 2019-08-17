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

# determine wether we process further, command and text separation
def preprocess_message(message, bot)
  # ignore if message is not from you
  return [false, '', ''] if message.from.id != Config.config['user']['tg_id']

  command_data = message.entities.find { |entity| entity.type == 'bot_command'}
  return [false, '', ''] if command_data.nil? # message to bot without command

  if command_data.offset != 0
    bot.api.send_message(chat_id: message.chat.id, text: 'Please give bot command first in your message :)')
    return [false, '', '']
  end

  long_command = message.text[0, command_data.length]
  command, bot_name = split_command_botname(long_command)
  text = message.text[command_data.length + 1, message.text.length]

  # ignore message cause it was adressed to another bot
  return [false, '', ''] if !bot_name.nil? && bot_name != Config.config['bot']['username']

  [true, command, text]
end

if $PROGRAM_NAME == __FILE__

  Telegram::Bot::Client.run(Config.config['bot']['token'], logger: Logger.new($stderr)) do |bot|
    bot.logger.info('Bot has been started')
    bot.listen do |message|

      begin

        continue_processing, command, text = preprocess_message(message, bot)
        next unless continue_processing

        reply = 'default reply'
        case command
        when '/start'
          reply = "Hello, #{message.from.first_name}"
        when '/stop'
          reply = "Bye, #{message.from.first_name}"
        when '/compliceuser'
          reply = Complice.userinfo
        when '/goals'
          reply = Complice.goals
        when '/today'
          reply = Complice.today_full
        when '/intention'
          response = Complice.add_new_intention(text)
          reply = if response == 'wrong intention format'
                    'Please use the intention format to add intentions!'
                  else
                    "You now have #{response} intentions for /today"
                  end
        when '/complete'
          successful = Complice.complete(text)
          reply = if successful
                    "Item #{text} completed!"
                  else
                    'Please give a valid zid to complete!'
                  end
        else
          reply = "I don't understand you :("
        end
        reply = 'reply from complice was empty' if reply.empty?
        bot.api.send_message(chat_id: message.chat.id, text: reply)
      rescue Exception => ex
        bot.logger.info("Caugth exception: #{ex}")
      end
    end
  end

end
