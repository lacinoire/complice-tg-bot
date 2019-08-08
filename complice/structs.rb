User = Struct.new(
  :username,
  :name,
)

ActiveGoals = Struct.new(
  :updated,
  :goals,
)

Goal = Struct.new(
  :_id,
  :code,
  :name,
  :color,
  :privacy,
  :oneliner,
  :topPriority,
  :startdate,
  :enddate,
  :stats,
)

TopPriority = Struct.new(
  :prid,
  :name,
  :spec,
  :ymd,
)

Stats = Struct.new(
  :totalPomos,
  :totalOutcomes,
  :maxStreak,
  :currentStreak,
)

TodayFull = Struct.new(
  :settings,
  :drafts,
  :recent,
  :timer,
  :core,
  :updated2,
  :updated,
  :billing,
)

TodayCore = Struct.new(
  :ymd,
  :list,
  :updated,
)

Intention = Struct.new(
  :t,
  :zid,
  :upd,
  :_id,
  :gids,
  :d, # done
  :pd, # num of assigned promodoros
  :u, # days undone
  :nvm, # is neverminded
) do
  def to_s
    t.to_s
  end
end
