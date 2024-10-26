module Decoder
  def self.bulk_decode_ids(model, ids)
    ids.map { |id| model.decode_id(id) }
  end
end
