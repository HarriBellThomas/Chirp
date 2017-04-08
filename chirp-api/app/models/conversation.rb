class Conversation < ActiveRecord::Base
    serialize :context, Hash
end
