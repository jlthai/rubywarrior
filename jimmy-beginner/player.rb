class Player
  attr_accessor :warrior

  def initialize
    @sludge_provoked = false
    @checked_behind = false
    @pivoted = false
    @healed = false
  end

  def play_turn warrior
    self.warrior = warrior
    analyze_field
    action
  end

  def analyze_field
    @in_combat = in_combat?
    @in_front = warrior.look[0].to_s
    @captive = warrior.feel.captive?
  end

  def action
    unless @checked_behind
      check_behind
    else
      @in_combat ? warrior.attack! : not_in_combat
    end
  end

  def not_in_combat
    if provokable && !(@sludge_provoked) 
      sludge_action
    elsif should_shoot
      warrior.shoot!
    elsif @captive
      warrior.rescue!
    elsif should_pivot
      warrior.pivot!
      @pivoted = true
    elsif @pivoted && warrior.health < 10 && !(@healed)
      warrior.rest!
      @healed = true
    else
      warrior.walk!; @sludge_provoked = false;
    end
  end

  def check_behind
    if three_spaces(:backward).any? { |s| s ==  "Captive" }
      if warrior.feel(:backward).captive?
        warrior.rescue! :backward
        @checked_behind = true
      else
        warrior.walk! :backward
      end
    elsif three_spaces(:backward).any? { |s| s == "Archer" }
      warrior.walk!
      @checked_behind = true
    else
      @checked_behind = true
      not_in_combat
    end
  end

  def sludge_action
    if provokable == "Sludge"
      warrior.shoot!
      @sludge_provoked = true
    elsif provokable == "Thick Sludge"
      warrior.shoot!
    end
  end

  def in_combat?
    close_range_creatures = ["Thick Sludge", "Sludge"]
    long_range_creatures = ["Wizard", "Archer"]
    all_creatures = close_range_creatures + long_range_creatures

    (all_creatures.any? { |c| c == warrior.look[0].to_s }) ? warrior.look[0].to_s : false
  end

  def three_spaces direction
    warrior.look(direction).map(&:to_s)
  end

  def provokable
    if warrior.look[1].to_s == "Sludge"
      "Sludge"
    elsif warrior.look[1].to_s == "Thick Sludge"
      "Thick Sludge"
    else
      false
    end
  end

  def should_pivot
    pivot_scenarios = [
      ["nothing", "wall", "wall"],
      ["wall", "wall", "wall"]
    ]

    (pivot_scenarios.any? {|ps| ps == three_spaces(:forward)}) &&
      !(warrior.feel.stairs?)
  end

  def should_shoot
    !(three_spaces(:forward).include?('Captive')) && three_spaces(:forward)[1..2].include?('Wizard')
  end
end
