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
        sender = Messenger::Bot::Transmitter.new(params["fbid"])
        sender.reply({ text: "Hello, again!" })
        puts sender.get_profile
        render :json => {:status => "success"}
    end
end
