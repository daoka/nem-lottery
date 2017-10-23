require 'nis'
require 'time'
require './lib/helper.rb'
require './lib/config.rb'

Nis.logger.level = Logger::DEBUG

env = ARGV[0]
p env

config = NemLottery::Config.new(env)

ADDRESS = config.address
BEGIN_LOTTERY_TIME = config.begin_time
END_LOTTERY_TIME = config.end_time
NIS_HOST = "192.3.61.243"
TARGET_MOSAIC = config.target_mosaic
MINMU_MOSAIC_AMOUNT = config.minimu_mosaic_amount
WINNER_COUNT = config.winner_count
ALTERNATE_COUNT = config.alternate_count
WINNER_EXPORT_PATH = "./tmp/" + env + "_winner.txt"
ALTERNATE_EXPORT_PATH = "./tmp/" + env + "_alternate.txt"


applicant_addresses = []
metadatas = []
winner_addresses = []
alternate_addresses = []
last_id = nil

loop do
  tmp_metadatas = NemLottery::Helper.transaction_meta_datas(last_id)
  break if tmp_metadatas.nil? || tmp_metadatas.size == 0

  if NemLottery::Helper.is_concat(transactions_last_metadata: tmp_metadatas.last, last_id: last_id)
    metadatas.concat(tmp_metadatas)
    last_id = NemLottery::Helper.get_id(metadata: metadatas.last)
  else
    break
  end

  break unless NemLottery::Helper.load_next?(last_metadata: metadatas.last)
end

metadatas.each do |metadata|
  if NemLottery::Helper.is_target_transaction(metadata: metadata)
    address_obj = Nis::Unit::Address.from_public_key(metadata.transaction.signer)
    applicant_addresses << address_obj.value
  end
end

shuffle_addresses = applicant_addresses.shuffle
winner_addresses = shuffle_addresses[0...WINNER_COUNT]
p winner_addresses
NemLottery::Helper.write_winner_addresses(winner_addresses)
alternate_addresses = shuffle_addresses[WINNER_COUNT...WINNER_COUNT+ALTERNATE_COUNT]
p alternate_addresses
NemLottery::Helper.write_alternate_addresses(alternate_addresses)
