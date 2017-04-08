require 'date'
require 'json'
require 'starling'
require 'wit_integration'

class WitIntegration

    def self.incoming(current, msg)

        actions = {
            send: -> (request, response) {
                puts("sending... #{response['text']}")
            },
            getBalance: -> (request) {
                context = {}
                entities = request['entities']

    	        Rails.logger.warn('fbid in action: ' + current.fbid)
                context['balance'] = Starling.balance(current.fbid)
                current.context = context
                current.save
                return context
            },
            transfer: -> (request) {
                context = {}
                entities = request['entities']

                contact = first_entity_value(entities, 'contact')
                amount_of_money = first_entity_value(entities, 'amount_of_money')

                if contact and amount_of_money

                    id = Starling.check_contact(current.fbid, contact)
                    if id
                        Starling.transfer(current.fbid, amount_of_money, id)
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

                current.context = context
                current.save
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

                current.context = context
                current.save
                return context
            },
            getSpending: -> (request) {
                context = {}
                entities = request['entities']

                datetime = first_entity_value(entities, 'datetime')

                if datetime
                    d = Date.parse(datetime)
                    simple_date = d.strftime('%Y-%m-%d')
                    response = Starling.spending(current.fbid, simple_date)
                    amount = 0 #Do something to calculate this!
                    context['amount'] = amount
                    context['niceDate'] = d.strftime('%d %b %y')
                    #context.delete('missingDatetime')
                else
                    context['missingDatetime'] = true
                    #context.delete('amount')
                    #context.delete('niceDate')
                end

                current.context = context
                current.save
                return context
            }
        }


        client = Wit.new(access_token: "FXLDTGT5HV5FGZX3VO2DEZXRH4B3K2NA", actions: actions)
        rsp = client.run_actions(current.fbid, msg, current.context)
        Rails.logger.warn(rsp.inspect)
        return rsp

    end

    def first_entity_value(entities, entity)
        return nil unless entities.has_key? entity
        val = entities[entity][0]['value']
        return nil if val.nil?
        return val.is_a?(Hash) ? val['value'] : val
    end


end
