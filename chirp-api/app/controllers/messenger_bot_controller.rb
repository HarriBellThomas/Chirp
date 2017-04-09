require 'date'
require 'starling'
require 'json'
require 'wit_integration'

class MessengerBotController < ActionController::Base
    def message(event, sender)
        # profile = sender.get_profile(field) # default field [:locale, :timezone, :gender, :first_name, :last_name, :profile_pic]

        unless event['message']['text'].nil?
            text = "#{event['message']['text']}"
            user = "#{event['sender']['id']}"
            @current = do_user_auth(user, text, sender)

            unless @current.nil?
                if text == "auth"
                    run_auth(text, sender, @current)
                elsif text == "showchart"
                    sender.reply({"attachment":{
                        "type":"image",
                        "payload":{
                            "url":"http://chart.apis.google.com/chart?cht=lc&chs=320x180&chdl=Balance&chco=cc3399&chxt=x,y&chxr=0,,,0|1,0&chm=B,ff5050,0,0,0&chd=t"
                        }
                    }})
                elsif text == "showbutton"
                    sender.reply({
                        "attachment":{
                          "type":"template",
                          "payload":{
                            "template_type":"button",
                            "text":"What do you want to do next?",
                            "buttons":[
                              {
                                "type":"web_url",
                                "url":"https://github.com/jun85664396/messenger-bot-rails",
                                "title":"Show Website"
                              },
                              {
                                "type":"postback",
                                "title":"Start Chatting",
                                "payload":"USER_DEFINED_PAYLOAD"
                              }
                            ]
                          }
                        }
                      })
                else
                    response = WitIntegration.incoming(@current, text, sender)
                end
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

        device_token = '3C082CC9244913BDF399EF05138BC43C9E33F769DEA82F8BD46438E6392D1F39'

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
        if s.nil? || s.expires < DateTime.now
            run_auth(msg, sender, c)
            return nil
        else
            return c
        end

    end

    def run_auth(msg, sender, current)
        sender.reply({ text: "We're just going to verify it's you. Please click on the push notification." })
        send_test_push_notification(current.uuid, msg)
    end

end
