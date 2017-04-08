class ApiController < ApplicationController

    skip_before_action :verify_authenticity_token, only: [:push_return]

    def show
    end

    def getbalance
        result = {
            :money => 50
        }
        render :json => result
    end

    def push_return
        c = Conversation.find_by_uuid(params["uuid"])
        sender = Messenger::Bot::Transmitter.new(c.fbid)
        sender.reply({"sender_action":"typing_on"})
        sender.reply({"attachment":{
            "type":"image",
            "payload":{
                "url":"http://media.giphy.com/media/qHho9D3nk3nS8/giphy.gif"
            }
        }})
        sender.reply({ text: "Thanks for authenticating! Let's see if we can answer your question." })
        sender.reply({"sender_action":"typing_off"})

        s = AuthSession.find_by_uuid(c.uuid)
        if s.nil?
            s = AuthSession.new
            s.uuid = c.uuid
        end

        s.expires = DateTime.parse((Time.now + 10*60).to_s)
        s.save


        response = WitIntegration.incoming(c, params["msg"])
        sender.reply({ text: "#{response}" })

        #puts sender.get_profile
        render :json => {:status => "success"}
    end
end
