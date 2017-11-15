require 'nis'
require 'time'

module NemLottery
  module Helper

    def self.transaction_meta_datas(last_id = nil)
      nis = Nis.new(host: NIS_HOST)
      nis.account_transfers_incoming(address: ADDRESS, id: last_id)
    end

    def self.load_next?(last_metadata: metadata)
      last_nem_time = Nis::Util.parse_nemtime(last_metadata.transaction.timestamp)
      begin_lottery_time =  Time.parse(BEGIN_LOTTERY_TIME)
      last_nem_time > begin_lottery_time
    end

    def self.get_id(metadata: metadata)
      metadata.meta.id
    end

    def self.is_concat(transactions_last_metadata: metadata, last_id: id)
      get_id(metadata: transactions_last_metadata) != last_id
    end

    def self.target_namespace
      TARGET_MOSAIC.split(":")[0]
    end

    def self.target_mosaic
      TARGET_MOSAIC.split(":")[1]
    end

    def self.is_target_mosaic_id?(mosaic_id)
      return mosaic_id[:namespaceId] == target_namespace && mosaic_id[:name] == target_mosaic
    end

    def self.is_target_mosaic_transfer?(transefer: transefer_transaction)
      return false unless is_timestamp_less_than_endtime(transefer.timeStamp)
      return false if transefer.mosaics.nil?
      transefer.mosaics.each do |mosaic|
        if is_target_mosaic_id?(mosaic[:mosaicId])
          if mosaic[:quantity] >= MINMU_MOSAIC_AMOUNT
            return true
          end
        end
      end
      return false
    end

    def self.is_target_transaction(metadata: metadata)
      p metadata.transaction.class
      transefer_transaction = nil
      if metadata.transaction.is_a?(Nis::Struct::TransferTransaction)
        transefer_transaction = metadata.transaction
      end

      if metadata.transaction.is_a?(Nis::Struct::MultisigTransaction)
        if metadata.transaction.otherTrans.is_a?(Nis::Struct::TransferTransaction)
          transefer_transaction = metadata.transaction.otherTrans
        end
      end

      return false if transefer_transaction.nil?

      is_target_mosaic_transfer?(transefer: transefer_transaction)
    end

    def self.is_timestamp_less_than_endtime(timestamp)
      t = Nis::Util.parse_nemtime(timestamp)
      end_time = Time.parse(END_LOTTERY_TIME)
      t < end_time
    end

    def self.write_addresses(addresses, filepath: path)
      File.open(filepath, "w") do |f|
        addresses.each do |address|
          f.puts(address)
        end
      end
    end

    def self.write_winner_addresses(winner_addresses)
      write_addresses(winner_addresses, filepath: WINNER_EXPORT_PATH)
    end

    def self.write_alternate_addresses(alternate_addresses)
      write_addresses(alternate_addresses, filepath: ALTERNATE_EXPORT_PATH)
    end

    def self.send_message(address: address, message: message, account_key: account_key)
      p address
      p message
      p account_key
      p NIS_HOST
      nis = Nis.new(host: NIS_HOST)
      keyPair = Nis::Keypair.new(account_key)
      tx = Nis::Transaction::Transfer.new(address, 0, message, {})
      req = Nis::Request::Announce.new(tx, keyPair)
      res = nis.transaction_announce(req)
      p "TransactionHash: #{res.transaction_hash}"
    end
  end
end
