require 'date'
require 'starling'
require 'json'
require 'wit'

class MessengerBotController < ActionController::Base
    def message(event, sender)
        # profile = sender.get_profile(field) # default field [:locale, :timezone, :gender, :first_name, :last_name, :profile_pic]

        unless event['message']['text'].nil?
            text = "#{event['message']['text']}"
            user = "#{event['sender']['id']}"
            @current = do_user_auth(user, text, sender)

            if text == "auth"
                run_auth(text)
            else
                response = WitIntegration.incoming(@current, text)
                sender.reply({ text: "#{response}" })
            end

        else
            sender.reply({ text: "The event text is nil. Reply: #{event['message']['text']}" })
        end


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



    def send_test_push_notification(id, msg)
        APNS.host = 'gateway.sandbox.push.apple.com'
        # gateway.sandbox.push.apple.com is default

        APNS.pem  = 'app/assets/CHIRPUSH.pem'
        # this is the file you just created

        APNS.port = 2195
        # this is also the default. Shouldn't ever have to set this, but just in case Apple goes crazy, you can.

        device_token = '12BF613DFAB7F8E763831FBFCFE3E339F518FB38CAD76ABADAB7D2BAC6F0D3E1'

        APNS.send_notification(
            device_token,
            :alert => 'Tap here to start a Chirp session.',
            :badge => 1,
            :sound => 'default',
            :other => {
                :chirp => {
                    :uuid => "#{id}",
                    :msg => "#{msg}"
                }
            }
        )
    end

    def do_user_auth(fbid, msg, sender)

        c = Conversation.find_by_fbid(fbid)
        if c.nil?
            c = Conversation.new
            c.uuid = SecureRandom.uuid
            c.fbid = fbid
            c.save
        end

        s = AuthSession.find_by_uuid(c.uuid)
        run_auth(msg, sender) if s.nil? || s.expires < DateTime.now

        return c

    end

    def run_auth(msg, sender)
        sender.reply({ text: "We're just going to verify it's you. Please click on the push notification." })
        send_test_push_notification(@current.uuid, msg)
    end

    def first_entity_value(entities, entity)
        return nil unless entities.has_key? entity
        val = entities[entity][0]['value']
        return nil if val.nil?
        return val.is_a?(Hash) ? val['value'] : val
    end



end
