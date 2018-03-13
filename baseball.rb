
PlayerInfoA = {1 => { attack: 32, defense: 3},
               2 => { attack: 11, defense: 4},
               3 => { attack: 21, defense: 1},
               4 => { attack: 48, defense: 5},
               5 => { attack: 21, defense: 12},
               6 => { attack: 15, defense: 2},
               7 => { attack: 51, defense: 5},
               8 => { attack: 13, defense: 6},
               9 => { attack: 11, defense: 66}}

PlayerInfoB = {1 => { attack: 30, defense: 1},
               2 => { attack: 101, defense: 2},
               3 => { attack: 40, defense: 3},
               4 => { attack: 120, defense: 4},
               5 => { attack: 100, defense: 5},
               6 => { attack: 55, defense: 6},
               7 => { attack: 71, defense: 7},
               8 => { attack: 51, defense: 8},
               9 => { attack: 31, defense: 9}}

Inning = 5  #回数

class Team
  attr_accessor :teamName
  attr_accessor :defenseSum
  attr_accessor :battingOrder
  attr_accessor :hitMeter
  attr_accessor :point
  attr_accessor :baseState
  attr_reader :playerInfo

  def initialize(teamName,playerInfo)
    @teamName = teamName
    @playerInfo = playerInfo  #チームのプレーヤー情報
    @defenseSum = 0
    @battingOrder = 1         #打席
    @point = 0                #得点
    @baseState = [false,false,false]  #塁の状態。[1塁,2塁,3塁]
    @hitMeter = {1 => 0,
                 2 => 0,
                 3 => 0,
                 4 => 0,
                 5 => 0,
                 6 => 0,
                 7 => 0,
                 8 => 0,
                 9 => 0}      #各プレーヤーのヒットメーター
    playerInfo.each do |key,value|   #チームの守備値合計を算出
      @defenseSum += value[:defense]
    end
  end
end

def runOneBase(team,runner)  #出塁。runnerはtrueなら打席から1塁へ向かうプレーヤーがいる
  if team.baseState[2]
    team.point += 1  #3塁にランナーがいる状態で走塁したら得点加算
  end
  team.baseState[2] = team.baseState[1]
  team.baseState[1] = team.baseState[0]
  team.baseState[0] = runner
end

def attack(team1,team2)  #team1が攻撃、team2が守備の回を実行
  sleep(1)
  outCount = 0
  while outCount < 3

    #ヒットメーター加算
    team1.hitMeter[team1.battingOrder] += team1.playerInfo[team1.battingOrder][:attack]

    #ヒットメーターが相手チーム守備値合計に達しヒットになったときの処理
    if team1.hitMeter[team1.battingOrder] >= team2.defenseSum

      #バッター出塁
      runOneBase(team1,true)

      #剰余に合わせてさらに走塁
      ((team1.hitMeter[team1.battingOrder] - team2.defenseSum) % 4).times do
        runOneBase(team1,false)
      end

      #剰余分をヒットメーターに収める
      team1.hitMeter[team1.battingOrder] %= team2.defenseSum

    else
      outCount += 1
    end

    team1.battingOrder += 1  #打者交代
    team1.battingOrder = 1 if team1.battingOrder == 10  #10人目は1人目へ

  end
  team1.baseState = [false,false,false]  #3アウト。走者帰ってこい
end

def game(a,b)
  attack(a,b)
  yield
  puts("回表終了=====")
  puts("#{a.teamName} #{a.point} - #{b.point} #{b.teamName}")
  puts("")

  attack(b,a)  #攻守交代して裏を開始
  yield
  puts("回裏終了=====")
  puts("#{a.teamName} #{a.point} - #{b.point} #{b.teamName}")
  puts("")
end

#チーム作成
teamA = Team.new("Giants",PlayerInfoA)
teamB = Team.new("Tigers",PlayerInfoB)

Inning.times do |i|
  game(teamA,teamB){ printf "=====#{i+1}" }
end

if teamA.point > teamB.point
  puts "Congratulations! #{teamA.teamName} won!"
elsif teamA.point < teamB.point
  puts "Congratulations! #{teamB.teamName} won!"
else
  puts "Draw!"
end
