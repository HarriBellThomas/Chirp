class MessengerBotController < ActionController::Base
    def message(event, sender)
        # profile = sender.get_profile(field) # default field [:locale, :timezone, :gender, :first_name, :last_name, :profile_pic]

        actions = {
            send: -> (request, response) {
                puts("sending... #{response['text']}")
            },
            transfer: -> (request) {
                context = request['context']
                entities = request['entities']

                contact = first_entity_value(entities, 'contact')
                amount_of_money = first_entity_value(entities, 'amount_of_money')

                if contact and amount_of_money
                    # TODO: Actually implement
                    context['response'] = 'Success!'
                    context.delete('missingContact')
                    context.delete('missingAmount')
                    context.delete('missingBoth')
                elsif contact and amount_of_money.nil?
                    context['missingAmount'] = true
                    context.delete('response')
                    context.delete('missingContact')
                    context.delete('missingBoth')
                elsif amount_of_money and contact.nil?
                    context['missingContact'] = true
                    context.delete('response')
                    context.delete('missingAmount')
                    context.delete('missingBoth')
                else
                    context['missingBoth'] = true
                    context.delete('response')
                    context.delete('missingContact')
                    context.delete('missingAmount')
                end

                return context
            },
            request: -> (request) {
                context = request['context']
                entities = request['entities']

                contact = first_entity_value(entities, 'contact')
                amount_of_money = first_entity_value(entities, 'amount_of_money')

                if contact and amount_of_money
                    # TODO: Actually implement
                    context['response'] = 'Success!'
                    context.delete('missingContact')
                    context.delete('missingAmount')
                    context.delete('missingBoth')
                elsif contact and amount_of_money.nil?
                    context['missingAmount'] = true
                    context.delete('response')
                    context.delete('missingContact')
                    context.delete('missingBoth')
                elsif amount_of_money and contact.nil?
                    context['missingContact'] = true
                    context.delete('response')
                    context.delete('missingAmount')
                    context.delete('missingBoth')
                else
                    context['missingBoth'] = true
                    context.delete('response')
                    context.delete('missingContact')
                    context.delete('missingAmount')
                end

                return context
            },
            getSpending: -> (request) {
                context = request['context']
                entities = request['entities']

                datetime = first_entity_value(entities, 'datetime')

                if datetime
                    # TODO: actually implement
                    context['amount'] = "£5000000000"
                    context['niceDate'] = "June a few years ago"
                    context.delete('missingDatetime')
                else
                    context['missingDatetime'] = true
                    context.delete('amount')
                    context.delete('niceDate')
                end

                return context
            },
        }


        unless event['message']['text'].nil?
            text = "#{event['message']['text']}"
            user = "#{event['sender']['id']}"
            @current = do_user_auth(user)

            if text == "auth"

                sender.reply({ text: "We're just going to verify it's you. Please click on the push notification." })
                send_test_push_notification(@current.fbid)

            else

                client = Wit.new(access_token: "FXLDTGT5HV5FGZX3VO2DEZXRH4B3K2NA", actions: actions)
                rsp = client.converse(@current.fbid, text, @current.context)
                #sender.reply({ text: "#{rsp['msg']}" })
                text_reply("#{rsp['msg']}", sender)

            end
        else
            text_reply("The event text is nil. Reply: #{event['message']['text']}", sender)
            #sender.reply({ text: "The event text is nil. Reply: #{event['message']['text']}" })
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



    def send_test_push_notification(id)
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
                    :fbid => "#{id}"
                }
            }
        )
    end

    def do_user_auth(fbid)

        c = Conversation.find_by_fbid(fbid)
        if c.nil?
            c = Conversation.new
            c.uuid = SecureRandom.uuid
            c.fbid = fbid
            c.save
        end

        return c

    end

    def first_entity_value(entities, entity)
        return nil unless entities.has_key? entity
        val = entities[entity][0]['value']
        return nil if val.nil?
        return val.is_a?(Hash) ? val['value'] : val
    end

    def text_reply(txt, sender)
        sender.reply({ text: txt })
    end

    def image_reply(url, sender)
        sender.reply({
            "attachment":{
                "type":"image",
                "payload":{
                    "url": url
                }
            }
        })
    end
