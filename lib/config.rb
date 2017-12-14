require 'yaml'

module NemLottery
  class Config
    def initialize(env)
      yaml = YAML.load_file("./config.yml")
      conf = yaml[env]
      @address = conf["address"]
      @begin_time = conf["begin_time"]
      @end_time = conf["end_time"]
      @target_mosaic = conf["target_mosaic"]
      @minimu_mosaic_amount = conf["minimu_mosaic_amount"]
      @winner_count = conf["winner_count"]
      @alternate_count = conf["alternate_count"]
      @notificate_private_key = conf["notificate_private_key"]
      @message = conf["notify_message"]
      @amount = conf["amount"]
    end

    attr_reader :address, :begin_time, :end_time, :target_mosaic, :winner_count, :alternate_count, :notificate_private_key, :minimu_mosaic_amount, :message, :amount
  end
end
