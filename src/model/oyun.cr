class Oyun < Granite::Base
	include CrSerializer(JSON)

	adapter mysql
	table_name oyunlar

	primary id : Int64
	field ad : String
	field bitti : Bool
	field user_uuid : String
	timestamps

	has_many oyuncular : Oyuncu

	def on_to_json(builder : JSON::Builder)
		builder.field "oyuncular", oyuncular
	end
end

class Oyuncu < Granite::Base
	include CrSerializer(JSON)

	adapter mysql
	table_name oyuncular

	primary id : Int64
	field ad : String
	timestamps

	belongs_to oyun : Oyun
	has_many skorlar : Skor

	def on_to_json(builder : JSON::Builder)
		builder.field "skorlar", skorlar
	end
end

class Skor < Granite::Base
	include CrSerializer(JSON)

	adapter mysql
	table_name skorlar

	primary id : Int64
	field sira : Int64
	field deger : Int64
	timestamps

	belongs_to oyuncu : Oyuncu
end

#Oyun.migrator.create
#Oyuncu.migrator.create
#Skor.migrator.create
