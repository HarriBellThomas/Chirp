class MessengerBotController < ActionController::Base
  def message(event, sender)
    # profile = sender.get_profile(field) # default field [:locale, :timezone, :gender, :first_name, :last_name, :profile_pic]

    actions = {
      send: -> (request, response) {
        puts("sending... #{response['text']}")
      },
      my_action: -> (request) {
        return request['context']
      },
    }

    client = Wit.new(access_token: ENV["WIT_ACCESS_TOKEN"], actions: actions)

    rsp = client.message(event['message']['text'])
    puts("Yay, got Wit.ai response: #{rsp}")


    sender.reply({ text: "Yay, got Wit.ai response: #{rsp}" })
  end

  def delivery(event, sender)
  end

  def postback(event, sender)
    payload = event["postback"]["payload"]
    case payload
    when :something
      #ex) process sender.reply({text: "button click event!"})
    end
  end
end
