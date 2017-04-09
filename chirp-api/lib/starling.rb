require 'rest-client'
require 'json'

class Starling
	def self.balance(fbid)
		u = Conversation.find_by(:fbid => fbid)
		access_token = u.starling_access
		rsp = RestClient.get('https://api-sandbox.starlingbank.com/api/v1/accounts/balance', headers={Accept: 'application/json', Authorization: 'Bearer '+access_token})
                hash_rsp = JSON.parse(rsp.body)
		return hash_rsp['availableToSpend']
	end

	def self.transfer(fbid, amount, contact_uuid)
		u = Conversation.find_by(:fbid => fbid)
		access_token = u.starling_access
		values = '{
			"destinationAccountUid":"'+contact_uuid+'"
			"payment":{
				"amount":'+amount.to_s+',
				"currency":"GBP"
			},
		}'
		rsp = RestClient.post('https://api-sandbox.starlingbank.com/api/v1/payments/local', values, {'Content-Type': 'application/json', Authorization: 'Bearer '+access_token})

	end

	def self.check_contact(fbid, contact_name)
		u = Conversation.find_by(:fbid => fbid)
		access_token = u.starling_access
		rsp = RestClient.get('https://api-sandbox.starlingbank.com/api/v1/contacts', headers={Accept: 'application/json', Authorization: 'Bearer '+access_token})
		hash_rsp = JSON.parse(rsp.body)

		id = nil
		hash_rsp['_embedded']['contacts'].each do |contact|
			if contact['name'] == contact_name
				id = contact['id']
			end
		end

		return id
	end

	def self.spending(fbid, simple_date)
		u = Conversation.find_by(:fbid => fbid)
		access_token = u.starling_access
		rsp = RestClient.get('https://api-sandbox.starlingbank.com/api/v1/transactions?from='+simple_date, headers={Accept: 'application/json', Authorization: 'Bearer '+access_token})
		return JSON.parse(rsp.body)
	end
end
