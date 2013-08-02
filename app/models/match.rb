class Match < ActiveRecord::Base
	serialize :data, Hash
end
