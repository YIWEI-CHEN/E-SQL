-- Source SQLite table: Ball_By_Ball
CREATE TABLE [bird_soccer_ball_by_ball] (
  [bird_soccer_ball_by_ballid] uniqueidentifier PRIMARY KEY,
  [bird_soccer_ball_by_ball_name] nvarchar(100),
  [bird_soccer_match_id] int,
  [bird_soccer_over_id] int,
  [bird_soccer_ball_id] int,
  [bird_soccer_innings_no] int,
  [bird_soccer_team_batting] int,
  [bird_soccer_team_bowling] int,
  [bird_soccer_striker_batting_position] int,
  [bird_soccer_striker] int,
  [bird_soccer_non_striker] int,
  [bird_soccer_bowler] int,
  [bird_soccer_match_lookup] uniqueidentifier /* lookup -> [bird_soccer_match]([bird_soccer_matchid]) */,
  [bird_soccer_match_lookupname] nvarchar(100),
  [bird_soccer_team_batting_lookup] uniqueidentifier /* lookup -> [bird_soccer_team]([bird_soccer_teamid]) */,
  [bird_soccer_team_batting_lookupname] nvarchar(100),
  [bird_soccer_team_bowling_lookup] uniqueidentifier /* lookup -> [bird_soccer_team]([bird_soccer_teamid]) */,
  [bird_soccer_team_bowling_lookupname] nvarchar(100),
  [bird_soccer_striker_lookup] uniqueidentifier /* lookup -> [bird_soccer_player]([bird_soccer_playerid]) */,
  [bird_soccer_striker_lookupname] nvarchar(100),
  [bird_soccer_non_striker_lookup] uniqueidentifier /* lookup -> [bird_soccer_player]([bird_soccer_playerid]) */,
  [bird_soccer_non_striker_lookupname] nvarchar(100),
  [bird_soccer_bowler_lookup] uniqueidentifier /* lookup -> [bird_soccer_player]([bird_soccer_playerid]) */,
  [bird_soccer_bowler_lookupname] nvarchar(100)
)

-- Source SQLite table: Batsman_Scored
CREATE TABLE [bird_soccer_batsman_scored] (
  [bird_soccer_batsman_scoredid] uniqueidentifier PRIMARY KEY,
  [bird_soccer_batsman_scored_name] nvarchar(100),
  [bird_soccer_match_id] int,
  [bird_soccer_over_id] int,
  [bird_soccer_ball_id] int,
  [bird_soccer_innings_no] int,
  [bird_soccer_runs_scored] int,
  [bird_soccer_match_lookup] uniqueidentifier /* lookup -> [bird_soccer_match]([bird_soccer_matchid]) */,
  [bird_soccer_match_lookupname] nvarchar(100)
)

-- Source SQLite table: Batting_Style
CREATE TABLE [bird_soccer_batting_style] (
  [bird_soccer_batting_styleid] uniqueidentifier PRIMARY KEY,
  [bird_soccer_batting_hand] nvarchar(50),
  [bird_soccer_batting_id] int
)

-- Source SQLite table: Bowling_Style
CREATE TABLE [bird_soccer_bowling_style] (
  [bird_soccer_bowling_styleid] uniqueidentifier PRIMARY KEY,
  [bird_soccer_bowling_skill] nvarchar(100),
  [bird_soccer_bowling_id] int
)

-- Source SQLite table: City
CREATE TABLE [bird_soccer_city] (
  [bird_soccer_cityid] uniqueidentifier PRIMARY KEY,
  [bird_soccer_city_name] nvarchar(100),
  [bird_soccer_city_id] int,
  [bird_soccer_country_id] int,
  [bird_soccer_country_lookup] uniqueidentifier /* lookup -> [bird_soccer_country]([bird_soccer_countryid]) */,
  [bird_soccer_country_lookupname] nvarchar(100)
)

-- Source SQLite table: Country
CREATE TABLE [bird_soccer_country] (
  [bird_soccer_countryid] uniqueidentifier PRIMARY KEY,
  [bird_soccer_country_name] nvarchar(100),
  [bird_soccer_country_id] int
)

-- Source SQLite table: Extra_Runs
CREATE TABLE [bird_soccer_extra_runs] (
  [bird_soccer_extra_runsid] uniqueidentifier PRIMARY KEY,
  [bird_soccer_extra_runs_name] nvarchar(100),
  [bird_soccer_match_id] int,
  [bird_soccer_over_id] int,
  [bird_soccer_ball_id] int,
  [bird_soccer_innings_no] int,
  [bird_soccer_extra_type_id] int,
  [bird_soccer_extra_runs] int,
  [bird_soccer_match_lookup] uniqueidentifier /* lookup -> [bird_soccer_match]([bird_soccer_matchid]) */,
  [bird_soccer_match_lookupname] nvarchar(100),
  [bird_soccer_extra_type_lookup] uniqueidentifier /* lookup -> [bird_soccer_extra_type]([bird_soccer_extra_typeid]) */,
  [bird_soccer_extra_type_lookupname] nvarchar(50)
)

-- Source SQLite table: Extra_Type
CREATE TABLE [bird_soccer_extra_type] (
  [bird_soccer_extra_typeid] uniqueidentifier PRIMARY KEY,
  [bird_soccer_extra_name] nvarchar(50),
  [bird_soccer_extra_id] int
)

-- Source SQLite table: Match
CREATE TABLE [bird_soccer_match] (
  [bird_soccer_matchid] uniqueidentifier PRIMARY KEY,
  [bird_soccer_match_name] nvarchar(100),
  [bird_soccer_match_id] int,
  [bird_soccer_match_date] datetime,
  [bird_soccer_win_margin] int,
  [bird_soccer_team_1] int,
  [bird_soccer_team_2] int,
  [bird_soccer_season_id] int,
  [bird_soccer_venue_id] int,
  [bird_soccer_toss_winner] int,
  [bird_soccer_toss_decide] int,
  [bird_soccer_win_type] int,
  [bird_soccer_outcome_type] int,
  [bird_soccer_match_winner] int,
  [bird_soccer_man_of_the_match] int,
  [bird_soccer_season_lookup] uniqueidentifier /* lookup -> [bird_soccer_season]([bird_soccer_seasonid]) */,
  [bird_soccer_season_lookupname] nvarchar(50),
  [bird_soccer_venue_lookup] uniqueidentifier /* lookup -> [bird_soccer_venue]([bird_soccer_venueid]) */,
  [bird_soccer_venue_lookupname] nvarchar(200),
  [bird_soccer_toss_decide_lookup] uniqueidentifier /* lookup -> [bird_soccer_toss_decision]([bird_soccer_toss_decisionid]) */,
  [bird_soccer_toss_decide_lookupname] nvarchar(50),
  [bird_soccer_toss_winner_lookup] uniqueidentifier /* lookup -> [bird_soccer_team]([bird_soccer_teamid]) */,
  [bird_soccer_toss_winner_lookupname] nvarchar(100),
  [bird_soccer_win_type_lookup] uniqueidentifier /* lookup -> [bird_soccer_win_by]([bird_soccer_win_byid]) */,
  [bird_soccer_win_type_lookupname] nvarchar(50),
  [bird_soccer_match_winner_lookup] uniqueidentifier /* lookup -> [bird_soccer_team]([bird_soccer_teamid]) */,
  [bird_soccer_match_winner_lookupname] nvarchar(100),
  [bird_soccer_man_of_the_match_lookup] uniqueidentifier /* lookup -> [bird_soccer_player]([bird_soccer_playerid]) */,
  [bird_soccer_man_of_the_match_lookupname] nvarchar(100),
  [bird_soccer_team_1_lookup] uniqueidentifier /* lookup -> [bird_soccer_team]([bird_soccer_teamid]) */,
  [bird_soccer_team_1_lookupname] nvarchar(100),
  [bird_soccer_team_2_lookup] uniqueidentifier /* lookup -> [bird_soccer_team]([bird_soccer_teamid]) */,
  [bird_soccer_team_2_lookupname] nvarchar(100),
  [bird_soccer_outcome_type_lookup] uniqueidentifier /* lookup -> [bird_soccer_outcome]([bird_soccer_outcomeid]) */,
  [bird_soccer_outcome_type_lookupname] nvarchar(50)
)

-- Source SQLite table: Out_Type
CREATE TABLE [bird_soccer_out_type] (
  [bird_soccer_out_typeid] uniqueidentifier PRIMARY KEY,
  [bird_soccer_out_name] nvarchar(50),
  [bird_soccer_out_id] int
)

-- Source SQLite table: Outcome
CREATE TABLE [bird_soccer_outcome] (
  [bird_soccer_outcomeid] uniqueidentifier PRIMARY KEY,
  [bird_soccer_outcome_type] nvarchar(50),
  [bird_soccer_outcome_id] int
)

-- Source SQLite table: Player
CREATE TABLE [bird_soccer_player] (
  [bird_soccer_playerid] uniqueidentifier PRIMARY KEY,
  [bird_soccer_player_name] nvarchar(100),
  [bird_soccer_player_id] int,
  [bird_soccer_dob] datetime,
  [bird_soccer_batting_hand] int,
  [bird_soccer_bowling_skill] int,
  [bird_soccer_country_name] int,
  [bird_soccer_batting_hand_lookup] uniqueidentifier /* lookup -> [bird_soccer_batting_style]([bird_soccer_batting_styleid]) */,
  [bird_soccer_batting_hand_lookupname] nvarchar(50),
  [bird_soccer_bowling_skill_lookup] uniqueidentifier /* lookup -> [bird_soccer_bowling_style]([bird_soccer_bowling_styleid]) */,
  [bird_soccer_bowling_skill_lookupname] nvarchar(100),
  [bird_soccer_country_lookup] uniqueidentifier /* lookup -> [bird_soccer_country]([bird_soccer_countryid]) */,
  [bird_soccer_country_lookupname] nvarchar(100)
)

-- Source SQLite table: Player_Match
CREATE TABLE [bird_soccer_player_match] (
  [bird_soccer_player_matchid] uniqueidentifier PRIMARY KEY,
  [bird_soccer_player_match_name] nvarchar(100),
  [bird_soccer_match_id] int,
  [bird_soccer_player_id] int,
  [bird_soccer_role_id] int,
  [bird_soccer_team_id] int,
  [bird_soccer_match_lookup] uniqueidentifier /* lookup -> [bird_soccer_match]([bird_soccer_matchid]) */,
  [bird_soccer_match_lookupname] nvarchar(100),
  [bird_soccer_player_lookup] uniqueidentifier /* lookup -> [bird_soccer_player]([bird_soccer_playerid]) */,
  [bird_soccer_player_lookupname] nvarchar(100),
  [bird_soccer_role_lookup] uniqueidentifier /* lookup -> [bird_soccer_rolee]([bird_soccer_roleeid]) */,
  [bird_soccer_role_lookupname] nvarchar(50),
  [bird_soccer_team_lookup] uniqueidentifier /* lookup -> [bird_soccer_team]([bird_soccer_teamid]) */,
  [bird_soccer_team_lookupname] nvarchar(100)
)

-- Source SQLite table: Rolee
CREATE TABLE [bird_soccer_rolee] (
  [bird_soccer_roleeid] uniqueidentifier PRIMARY KEY,
  [bird_soccer_role_desc] nvarchar(50),
  [bird_soccer_role_id] int
)

-- Source SQLite table: Season
CREATE TABLE [bird_soccer_season] (
  [bird_soccer_seasonid] uniqueidentifier PRIMARY KEY,
  [bird_soccer_season_name] nvarchar(50),
  [bird_soccer_season_id] int,
  [bird_soccer_season_year] int,
  [bird_soccer_man_of_the_series] int,
  [bird_soccer_orange_cap] int,
  [bird_soccer_purple_cap] int,
  [bird_soccer_man_of_the_series_lookup] uniqueidentifier /* lookup -> [bird_soccer_player]([bird_soccer_playerid]) */,
  [bird_soccer_man_of_the_series_lookupname] nvarchar(100),
  [bird_soccer_orange_cap_lookup] uniqueidentifier /* lookup -> [bird_soccer_player]([bird_soccer_playerid]) */,
  [bird_soccer_orange_cap_lookupname] nvarchar(100),
  [bird_soccer_purple_cap_lookup] uniqueidentifier /* lookup -> [bird_soccer_player]([bird_soccer_playerid]) */,
  [bird_soccer_purple_cap_lookupname] nvarchar(100)
)

-- Source SQLite table: Team
CREATE TABLE [bird_soccer_team] (
  [bird_soccer_teamid] uniqueidentifier PRIMARY KEY,
  [bird_soccer_team_name] nvarchar(100),
  [bird_soccer_team_id] int
)

-- Source SQLite table: Toss_Decision
CREATE TABLE [bird_soccer_toss_decision] (
  [bird_soccer_toss_decisionid] uniqueidentifier PRIMARY KEY,
  [bird_soccer_toss_name] nvarchar(50),
  [bird_soccer_toss_id] int
)

-- Source SQLite table: Umpire
CREATE TABLE [bird_soccer_umpire] (
  [bird_soccer_umpireid] uniqueidentifier PRIMARY KEY,
  [bird_soccer_umpire_name] nvarchar(100),
  [bird_soccer_umpire_id] int,
  [bird_soccer_umpire_country] int,
  [bird_soccer_umpire_country_lookup] uniqueidentifier /* lookup -> [bird_soccer_country]([bird_soccer_countryid]) */,
  [bird_soccer_umpire_country_lookupname] nvarchar(100)
)

-- Source SQLite table: Venue
CREATE TABLE [bird_soccer_venue] (
  [bird_soccer_venueid] uniqueidentifier PRIMARY KEY,
  [bird_soccer_venue_name] nvarchar(200),
  [bird_soccer_venue_id] int,
  [bird_soccer_city_id] int,
  [bird_soccer_city_lookup] uniqueidentifier /* lookup -> [bird_soccer_city]([bird_soccer_cityid]) */,
  [bird_soccer_city_lookupname] nvarchar(100)
)

-- Source SQLite table: Wicket_Taken
CREATE TABLE [bird_soccer_wicket_taken] (
  [bird_soccer_wicket_takenid] uniqueidentifier PRIMARY KEY,
  [bird_soccer_wicket_taken_name] nvarchar(100),
  [bird_soccer_match_id] int,
  [bird_soccer_over_id] int,
  [bird_soccer_ball_id] int,
  [bird_soccer_innings_no] int,
  [bird_soccer_player_out] int,
  [bird_soccer_kind_out] int,
  [bird_soccer_fielders] int,
  [bird_soccer_match_lookup] uniqueidentifier /* lookup -> [bird_soccer_match]([bird_soccer_matchid]) */,
  [bird_soccer_match_lookupname] nvarchar(100),
  [bird_soccer_player_out_lookup] uniqueidentifier /* lookup -> [bird_soccer_player]([bird_soccer_playerid]) */,
  [bird_soccer_player_out_lookupname] nvarchar(100),
  [bird_soccer_kind_out_lookup] uniqueidentifier /* lookup -> [bird_soccer_out_type]([bird_soccer_out_typeid]) */,
  [bird_soccer_kind_out_lookupname] nvarchar(50),
  [bird_soccer_fielders_lookup] uniqueidentifier /* lookup -> [bird_soccer_player]([bird_soccer_playerid]) */,
  [bird_soccer_fielders_lookupname] nvarchar(100)
)

-- Source SQLite table: Win_By
CREATE TABLE [bird_soccer_win_by] (
  [bird_soccer_win_byid] uniqueidentifier PRIMARY KEY,
  [bird_soccer_win_type] nvarchar(50),
  [bird_soccer_win_id] int
)