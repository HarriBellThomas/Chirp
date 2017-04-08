class MessengerBotController < ActionController::Base
  def message(event, sender)
    # profile = sender.get_profile(field) # default field [:locale, :timezone, :gender, :first_name, :last_name, :profile_pic]

    actions = {
      send: -> (request, response) {
        puts("sending... #{response['text']}")
      },
      my_action: -> (request) {
        return request['context']
      },
    }

    client = Wit.new(access_token: ENV["WIT_ACCESS_TOKEN"], actions: actions)

    unless event['message']['text'].nil?
        text = "#{event['message']['text']}"
        puts text
        sender.reply({ text: "Not nil!" })
        sender.reply({ text: text })
        #     rsp = client.message("#{event['message']['text']}")

    else
        sender.reply({ text: "The event text is nil. Reply: #{event['message']['text']}" })
    end

    sender.reply({
    "attachment":{
      "type":"image",
      "payload":{
        "url":"https://github.com/apple-touch-icon.png"
      }
    }
  })

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






sender.reply({
    "attachment":{
      "type":"template",
      "payload":{
        "template_type":"generic",
        "elements":[
          {
            "title":"Classic White T-Shirt",
            "image_url":"http://petersapparel.parseapp.com/img/item100-thumb.png",
            "subtitle":"Soft white cotton t-shirt is back in style",
            "buttons":[
              {
                "type":"web_url",
                "url":"https://petersapparel.parseapp.com/view_item?item_id=100",
                "title":"View Item"
              },
              {
                "type":"web_url",
                "url":"https://petersapparel.parseapp.com/buy_item?item_id=100",
                "title":"Buy Item"
              },
              {
                "type":"postback",
                "title":"Bookmark Item",
                "payload":"USER_DEFINED_PAYLOAD_FOR_ITEM100"
              }
            ]
          },
          {
            "title":"Classic Grey T-Shirt",
            "image_url":"http://petersapparel.parseapp.com/img/item101-thumb.png",
            "subtitle":"Soft gray cotton t-shirt is back in style",
            "buttons":[
              {
                "type":"web_url",
                "url":"https://petersapparel.parseapp.com/view_item?item_id=101",
                "title":"View Item"
              },
              {
                "type":"web_url",
                "url":"https://petersapparel.parseapp.com/buy_item?item_id=101",
                "title":"Buy Item"
              },
              {
                "type":"postback",
                "title":"Bookmark Item",
                "payload":"USER_DEFINED_PAYLOAD_FOR_ITEM101"
              }
            ]
          }
        ]
      }
    }
  })


  sender.reply({
      "attachment":{
        "type":"template",
        "payload":{
          "template_type":"receipt",
          "recipient_name":"Stephane Crozatier",
          "order_number":"12345678902",
          "currency":"USD",
          "payment_method":"Visa 2345",
          "order_url":"http://petersapparel.parseapp.com/order?order_id=123456",
          "timestamp":"1428444852",
          "elements":[
            {
              "title":"Classic White T-Shirt",
              "subtitle":"100% Soft and Luxurious Cotton",
              "quantity":2,
              "price":50,
              "currency":"USD",
              "image_url":"http://petersapparel.parseapp.com/img/whiteshirt.png"
            },
            {
              "title":"Classic Gray T-Shirt",
              "subtitle":"100% Soft and Luxurious Cotton",
              "quantity":1,
              "price":25,
              "currency":"USD",
              "image_url":"http://petersapparel.parseapp.com/img/grayshirt.png"
            }
          ],
          "address":{
            "street_1":"1 Hacker Way",
            "street_2":"",
            "city":"Menlo Park",
            "postal_code":"94025",
            "state":"CA",
            "country":"US"
          },
          "summary":{
            "subtotal":75.00,
            "shipping_cost":4.95,
            "total_tax":6.19,
            "total_cost":56.14
          },
          "adjustments":[
            {
              "name":"New Customer Discount",
              "amount":20
            },
            {
              "name":"$10 Off Coupon",
              "amount":10
            }
          ]
        }
      }
    })

    
    # if !event['message']['text'].nil?
    #     puts("Yay, got Wit.ai response: #{rsp}")
    #
    #
    #     sender.reply({ text: "Yay, got Wit.ai response: #{rsp}" })
    # else
    #     sender.reply({ text: "Blank format" })
    # end

    #sender.reply({ text: "Reply: #{event['message']['text']}" })
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
end