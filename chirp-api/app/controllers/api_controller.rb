class ApiController < ApplicationController
    def show
    end

    def getbalance
        result = {
            :money => 50
        }
        render :json => result
    end

    def messenger_webhook
        if params["hub.verify_token"] == "c671305a-0fd5-40a5-8859-03dbb9f76d05"
            render :text => params["hub.challenge"]
        else
            render :text => "Wrong token"
        end
    end
end
