task :greet do
	puts "Hello World!" 
end

task :ask => :greet do
	puts "How are you?" 
end

namespace :steam do 
	namespace :dota2 do 

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
		
		task :getmatchdataseq => [:environment, :setapikey] do
			data = WebApi.json!('IDOTA2Match_570','GetMatchHistoryBySequenceNum',version = 1,params={:matches_requested=>100})
			#can only request 100 matches at once.
			# start_at_match_seq_num(seq#) 
			# sequence number: data[:matches][#][:match_seq_num
			
		end	

	end
end
