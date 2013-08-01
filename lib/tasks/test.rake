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
			val	= val['results']['heroes']
			val.each do |p|
				d = DotaHeroes.new
				d.name = p['name'].gsub('npc_dota_hero_','')
				d.save
			end

		end
	end
end
