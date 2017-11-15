require 'nis'
require 'time'
require './lib/helper.rb'
require './lib/config.rb'

Nis.logger.level = Logger::DEBUG

env = ARGV[0]
p env

config = NemLottery::Config.new(env)

ADDRESS = config.address
NIS_HOST = "nis-testnet.44uk.net"
WINNER_EXPORT_PATH = "./tmp/" + env + "_winner.txt"
MESSAGE = config.message
SEND_ACCOUNT_KEY = config.notificate_private_key

File.open(WINNER_EXPORT_PATH, "r") do |f|
  f.each_line do |l|
    address = l.chomp
    NemLottery::Helper.send_message(address: address, message: MESSAGE, account_key: SEND_ACCOUNT_KEY)
  end
end
