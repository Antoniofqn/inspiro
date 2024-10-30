class ClusterNote < ApplicationRecord
  belongs_to :cluster
  belongs_to :note
end
