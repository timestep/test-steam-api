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
			binding.pry
			matches.each do |m|
				d = Match.new
				d.match_id = m['match_id']
				d.save
			end
		end
	end
end
