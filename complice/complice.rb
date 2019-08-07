require 'representable/json'
require 'httparty'
require 'pp'

load 'complice/structs.rb'
load 'complice/representers.rb'

# queries the complice v0 api
class Complice
  include Config
  include HTTParty
  base_uri 'https://complice.co/api/v0/u/me/'
  format :json
  default_params auth_token: Config.config['complice']['auth_token']

  def self.userinfo
    userinfo = get('/userinfo.json', query: default_params)
    user = UserRepresenter.new(User.new).from_json(userinfo&.body)
    user
  end

  def self.goals_active
    body = get('/goals/active.json', query: default_params)&.body
    active_goals = ActiveGoalsRepresenter.new(ActiveGoals.new).from_json(body)
    active_goals
  end

  def self.goals
    goals_active.goals.map { |goal| print_goal(goal) } .join("\n")
  end

  def self.today_full
    body = get('/today/full.json', query: default_params)&.body
    puts body
    today = TodayFullRepresenter.new(TodayFull.new).from_json(body)
    pp today
    goals = goals_active.goals
    today.core.list.map { |intention| print_intention(intention, goals) } .join("\n")
  end

  def self.add_new_intention(raw_intentions)
    body = post('/intentions', query: default_params.merge('raw' => raw_intentions, 'response' => 'count'))&.body
    JSON.parse(body)['intentionsCount']
  end

  def self.complete(zid)
    body = post("/completeById/#{zid}", query: default_params)&.body
    puts JSON.pretty_generate(JSON.parse(body))
  end

  def self.print_intention(intention, goals)
    goalnums = intention.gids.map { |gid| goals.find { |goal| goal._id == gid } .code}
    "#{goalnums.join(',')}) #{intention.t} || #{intention.zid}"
  end

  def self.print_goal(goal)
    "#{goal.code}) #{goal.name}"
  end

end
