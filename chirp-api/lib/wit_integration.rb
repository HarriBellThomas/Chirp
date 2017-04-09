require 'date'
require 'json'
require 'starling'
require 'wit_integration'
require 'rest-client'

class WitIntegration

    def self.incoming(current, msg, sender)

        actions = {
            send: -> (request, response) {
                sender.reply({ text: "#{response['text']}" })
            },
            getBalance: -> (request) {
                context = {}
                entities = request['entities']

                context['balance'] = Starling.balance(current.fbid)
                current.context = context
                current.save
                return context
            },
            transfer: -> (request) {
                context = {}
                entities = request['entities']

                contact = WitIntegration.first_entity_value(entities, 'contact')
                amount_of_money = WitIntegration.first_entity_value(entities, 'amount_of_money')

                if contact and amount_of_money

                    id = Starling.check_contact(current.fbid, contact)
                    if id
                        Starling.transfer(current.fbid, amount_of_money, id)
                        context['transferSuccess'] = 'Transferred'+amount_of_money+'to'+contact
                    else
                        context['notValidContact'] = true
                    end
                elsif contact and amount_of_money.nil?
                    context['missingAmount'] = true
                elsif amount_of_money and contact.nil?
                    context['missingContact'] = true
                else
                    context['missingBoth'] = true
                end

                current.context = context
                current.save
                return context
            },
=begin
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
=end
            getSpending: -> (request) {
                context = {}
                entities = request['entities']

                datetime = first_entity_value(entities, 'datetime')

                if datetime
                    d = Date.parse(datetime)
                    simple_date = d.strftime('%Y-%m-%d')
                    rsp = Starling.spending(current.fbid, simple_date)
		    # Send data to graph maker
		    graph_rsp = RestClient.post('https://graphs.pyri.co/dem2.php', rsp.to_json, content_type: :json)
                    amount = 0 #TODO: graph_rsp something
		    graph = 0 #TODO: graph_rsp something
                    context['amount'] = amount
                    context['niceDate'] = d.strftime('%d %b %y')
                else
                    context['missingDatetime'] = true
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

    def self.first_entity_value(entities, entity)
        return nil unless entities.has_key? entity
        val = entities[entity][0]['value']
        return nil if val.nil?
        return val.is_a?(Hash) ? val['value'] : val
    end


end
