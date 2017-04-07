class ApiController < ApplicationController
    def show
    end

    def getbalance
        result = {
            :money => 50
        }
        render :json => result
    end
end
