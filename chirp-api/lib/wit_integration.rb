require 'date'
require 'json'
require 'starling'
require 'wit_integration'
require 'rest-client'
require 'uri'

class WitIntegration

    def self.incoming(current, msg, sender)

        actions = {
            send: -> (request, response) {
                sender.reply({ text: "#{response['text']}" })
            },
	    clearContext: -> (request) {
	        context = {}
                current.context = context
                current.save
                return context
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
		    Rails.logger.warn("CONTACT:   " + id.inspect)
                    if id
                        #Starling.transfer(current.fbid, amount_of_money, id)
                        context['transferSuccess'] = 'Transferred £' + amount_of_money.to_s + ' to ' + contact
		        context.delete('notValidContact')
			context.delete('missingAmount')
			context.delete('missingContact')
			context.delete('missingBoth')
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
		    #Rails.logger.warn('STARLING SPEND RETURN:  '+rsp.inspect)
		    # Send data to graph maker
		    graph_rsp = RestClient.post('https://graphs.pyri.co/dem2.php', :data => rsp.to_json)
	            hash_rsp = JSON.parse(graph_rsp.body)
		    #Rails.logger.warn('GRAPH SERV RESPONSE:   ' + graph_rsp.inspect)
		    Rails.logger.warn('SPENDING TRANSACTION HASH    ' + hash_rsp.inspect)
                    amount = hash_rsp['sum_over_period'] #TODO: graph_rsp something
		    sender.reply({"attachment":{
                        "type":"image",
                        "payload":{
                            "url":URI.unescape(hash_rsp['img_f']).gsub!("&amp;","&")
                        }
                    }})
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
