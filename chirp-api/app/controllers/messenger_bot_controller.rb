require 'date'
require 'starling'

class MessengerBotController < ActionController::Base
    def message(event, sender)
        # profile = sender.get_profile(field) # default field [:locale, :timezone, :gender, :first_name, :last_name, :profile_pic]

        actions = {
            send: -> (request, response) {
                puts("sending... #{response['text']}")
            },
            getBalance: -> (request) {
                context = {}
                entities = request['entities']

                context['balance'] = Starling.getBalance(@current.fbid)
                @current.context = context
                @current.save
                return context
            },
            transfer: -> (request) {
                context = {}
                entities = request['entities']

                contact = first_entity_value(entities, 'contact')
                amount_of_money = first_entity_value(entities, 'amount_of_money')

                if contact and amount_of_money

                    id = Starling.check_contact(@current.fbid, contact)
                    if id
                        Starling.transfer(@current.fbid, amount_of_money, id)
                        context['response'] = 'Transferred'+amount_of_money+'to'+contact
                    else
                        context['notValidContact'] = true
                    end
                    #context.delete('missingContact')
                    #context.delete('missingAmount')
                    #context.delete('missingBoth')
                elsif contact and amount_of_money.nil?
                    context['missingAmount'] = true
                    #context.delete('response')
                    #context.delete('missingContact')
                    #context.delete('missingBoth')
                elsif amount_of_money and contact.nil?
                    context['missingContact'] = true
                    #context.delete('response')
                    #context.delete('missingAmount')
                    #context.delete('missingBoth')
                else
                    context['missingBoth'] = true
                    #context.delete('response')
                    #context.delete('missingContact')
                    #context.delete('missingAmount')
                end

                @current.context = context
                @current.save
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
                    #context.delete('missingContact')
                    #context.delete('missingAmount')
                    #context.delete('missingBoth')
                elsif contact and amount_of_money.nil?
                    context['missingAmount'] = true
                    #context.delete('response')
                    #context.delete('missingContact')
                    #context.delete('missingBoth')
                elsif amount_of_money and contact.nil?
                    context['missingContact'] = true
                    #context.delete('response')
                    #context.delete('missingAmount')
                    #context.delete('missingBoth')
                else
                    context['missingBoth'] = true
                    #context.delete('response')
                    #context.delete('missingContact')
                    #context.delete('missingAmount')
                end

                @current.context = context
                @current.save
                return context
            },
            getSpending: -> (request) {
                context = {}
                entities = request['entities']

                datetime = first_entity_value(entities, 'datetime')

                if datetime
                    d = Date.parse(datetime)
                    simple_date = d.strftime('%Y-%m-%d')
                    response = Starling.spending(@current.fbid, simple_date)
                    amount = 0 #Do something to calculate this!
                    context['amount'] = amount
                    context['niceDate'] = d.strftime('%d %b %y')
                    #context.delete('missingDatetime')
                else
                    context['missingDatetime'] = true
                    #context.delete('amount')
                    #context.delete('niceDate')
                end

                @current.context = context
                @curent.save
                return context
            }
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
                sender.reply({ text: "#{rsp['msg']}" })

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



end
