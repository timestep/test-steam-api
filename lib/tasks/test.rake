task :greet do
	puts "Hello World!" 
end

task :ask => :greet do
	puts "How are you?" 
end

namespace :steam do 
	namespace :dota2 do 
		task :cleardb => :environment do
			puts "Destroying DB"
			Match.destroy_all
			puts "Matches Cleared"
		end

		task :setapikey => :environment do
			WebApi.api_key = User.first.steamapikey
		end

		task :gethero => [:environment, :setapikey] do

			val = JSON.parse(WebApi.json('IEconDOTA2_570','GetHeroes'))
			val	= val['result']['heroes']
			val.each do |p|
				d = DotaHeroes.new
				d.name = p['name'].gsub('npc_dota_hero_','')
				d.save
			end
		end

		task :getmatchid => [:environment, :setapikey] do
			matches = JSON.parse(WebApi.json('IDOTA2Match_570','GetMatchHistory',version = 1,params={:min_players=>10}))
			matches = matches['result']['matches']
			matches.each do |m|
				d = Match.new
				d.match_id = m['match_id']
				d.save
			end
		end

		task :getmatchdata => [:environment, :setapikey, :getmatchid] do
			m_id = []
			Match.all.each do |m|
				data = JSON.parse(WebApi.json('IDOTA2MATCH_570','GetMatchDetails',version=1,params={:match_id=>m.match_id})) 
				data = data['result']
				if data['human_players'] == 10
					m.data = data
					m.save
				end
			end
		end
		
		task :getmatchdataseq => [:environment,:cleardb, :setapikey] do
			nextMatch = 0
			while true
				puts "Getting API Data"
				data = getSeqMatchData(nextMatch)
				puts "Validating Api Data"
	
				if data[:status] == 1
					puts "Rearraging Data"
					data = data[:matches]
					puts "Beinning Loop"
					data.each do |d|
						puts "Checking for 10 human_players"
						if d[:human_players]==10
							puts "Creating New Match"
							m = Match.new
							puts "Assigning Match #{d[:match_seq_num]} to data"
							m.data = d
							m.save
							puts "Data saved to Match# #{m.id}"
						end
					end
				end
				puts "Finding last seq num of API data"
				break if nextMatch == data.last[:match_seq_num]
				nextMatch = data.last[:match_seq_num]
			end	
		end	
		task :feedhero do => [:environment]
			Match.all.each do |m|
				m.data[:players].each do |p|
					heroData = DotaHeroes.find_by_id(p[:hero_id])
					heroData.numMatches += 1
					heroData.save
				end
			end
		end
	end
end

private 

def getSeqMatchData(startMatchId=0)
	data = WebApi.json!('IDOTA2Match_570',
				'GetMatchHistoryBySequenceNum',
				version = 1,params={
					:matches_requested=>100,
					:player=>10, 
					:start_at_match_seq_num => startMatchId
					})
	return data
end

