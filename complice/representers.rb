class UserRepresenter < Representable::Decorator
  include Representable::JSON

  property :username
  property :name
end

class GoalRepresenter < Representable::Decorator
  include Representable::JSON

  property :_id
  property :code
  property :name
  property :color
  property :privacy
  property :oneliner

  property :topPriority, class: TopPriority do
    property :prid
    property :name
    property :spec
    property :ymd
  end

  property :startdate
  property :enddate

  property :stats, class: Stats do
    property :totalPomos
    property :totalOutcomes
    property :maxStreak
    property :currentStreak
  end
end

class ActiveGoalsRepresenter < Representable::Decorator
  include Representable::JSON

  property :updated
  collection :goals, decorator: GoalRepresenter, class: Goal
end

class TodayFullRepresenter < Representable::Decorator
  include Representable::JSON

  property :settings # more, eg. pomo settings
  property :drafts # more in here, eg. dailys
  property :recent # review status, notdones
  property :timer # pomo timer
  property :core, class: TodayCore do

    property :ymd
    collection :list, class: Intention do
      property :t
      property :zid
      property :upd
      property :_id
      collection :gids
    end

    property :updated
  end
  property :updated2
  property :updated
  property :billing # eg. days left
end
