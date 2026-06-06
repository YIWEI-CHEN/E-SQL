-- question_id=0 source_index=1787
SELECT COUNT([bird_soccer_player_id]) FROM [bird_soccer_player] WHERE DATEPART(year, [bird_soccer_dob]) > 1985;

-- question_id=1 source_index=1788
SELECT COUNT([bird_soccer_match_id]) FROM [bird_soccer_match] WHERE DATEPART(year, [bird_soccer_match_date]) = '2008' AND DATEPART(month, [bird_soccer_match_date]) = '5';

-- question_id=2 source_index=1789
SELECT COUNT([bird_soccer_match_id]) FROM [bird_soccer_match] WHERE [bird_soccer_man_of_the_match] = 41;

-- question_id=3 source_index=1790
SELECT [bird_soccer_match_id] FROM [bird_soccer_match] WHERE DATEPART(year, [bird_soccer_match_date]) = '2008';

-- question_id=4 source_index=1791
SELECT COUNT(CASE WHEN [T2].[bird_soccer_country_name] = 'Australia' THEN [T1].[bird_soccer_player_id] ELSE NULL END) FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_country] AS [T2] ON [T1].[bird_soccer_country_name] = [T2].[bird_soccer_country_id];

-- question_id=5 source_index=1792
SELECT TOP 1 [T1].[bird_soccer_country_name] FROM [bird_soccer_country] AS [T1] INNER JOIN [bird_soccer_player] AS [T2] ON [T2].[bird_soccer_country_name] = [T1].[bird_soccer_country_id] WHERE NOT [T2].[bird_soccer_country_name] IS NULL ORDER BY [T2].[bird_soccer_dob];

-- question_id=6 source_index=1793
SELECT [T1].[bird_soccer_bowling_skill] FROM [bird_soccer_bowling_style] AS [T1] INNER JOIN [bird_soccer_player] AS [T2] ON [T2].[bird_soccer_bowling_skill] = [T1].[bird_soccer_bowling_id] WHERE [T2].[bird_soccer_player_name] = 'SC Ganguly';

-- question_id=7 source_index=1794
SELECT SUM(CASE WHEN DATEPART(year, [T1].[bird_soccer_dob]) > 1985 THEN 1 ELSE 0 END) FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_batting_style] AS [T2] ON [T1].[bird_soccer_batting_hand] = [T2].[bird_soccer_batting_id] WHERE [T2].[bird_soccer_batting_hand] = 'Right-hand bat';

-- question_id=8 source_index=1795
SELECT [T2].[bird_soccer_player_name] FROM [bird_soccer_country] AS [T1] INNER JOIN [bird_soccer_player] AS [T2] ON [T2].[bird_soccer_country_name] = [T1].[bird_soccer_country_id] INNER JOIN [bird_soccer_batting_style] AS [T3] ON [T2].[bird_soccer_batting_hand] = [T3].[bird_soccer_batting_id] WHERE [T1].[bird_soccer_country_name] = 'Australia' AND [T3].[bird_soccer_batting_hand] = 'Right-hand bat';

-- question_id=9 source_index=1796
SELECT [T2].[bird_soccer_bowling_skill] FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_bowling_style] AS [T2] ON [T1].[bird_soccer_bowling_skill] = [T2].[bird_soccer_bowling_id] INNER JOIN [bird_soccer_country] AS [T3] ON [T1].[bird_soccer_country_name] = [T3].[bird_soccer_country_id] WHERE [T3].[bird_soccer_country_name] = 'Australia' GROUP BY [T2].[bird_soccer_bowling_skill];

-- question_id=10 source_index=1797
SELECT MIN([T1].[bird_soccer_dob]) FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_bowling_style] AS [T2] ON [T1].[bird_soccer_bowling_skill] = [T2].[bird_soccer_bowling_id] WHERE [T2].[bird_soccer_bowling_skill] = 'Legbreak';

-- question_id=11 source_index=1798
SELECT TOP 1 [T1].[bird_soccer_bowling_skill] FROM [bird_soccer_bowling_style] AS [T1] INNER JOIN [bird_soccer_player] AS [T2] ON [T2].[bird_soccer_bowling_skill] = [T1].[bird_soccer_bowling_id] GROUP BY [T1].[bird_soccer_bowling_skill] ORDER BY COUNT([T1].[bird_soccer_bowling_skill]) DESC;

-- question_id=12 source_index=1799
SELECT [T2].[bird_soccer_player_name] FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_player] AS [T2] ON [T2].[bird_soccer_player_id] = [T1].[bird_soccer_man_of_the_match] WHERE [T1].[bird_soccer_match_date] = '2008-04-18';

-- question_id=13 source_index=1800
SELECT SUM(CASE WHEN [T3].[bird_soccer_role_desc] = 'Captain' THEN 1 ELSE 0 END) FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_player_match] AS [T2] ON [T1].[bird_soccer_player_id] = [T2].[bird_soccer_player_id] INNER JOIN [bird_soccer_rolee] AS [T3] ON [T2].[bird_soccer_role_id] = [T3].[bird_soccer_role_id] WHERE [T1].[bird_soccer_player_name] = 'SC Ganguly';

-- question_id=14 source_index=1801
SELECT [T2].[bird_soccer_role_id] FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_player_match] AS [T2] ON [T1].[bird_soccer_player_id] = [T2].[bird_soccer_player_id] INNER JOIN [bird_soccer_rolee] AS [T3] ON [T2].[bird_soccer_role_id] = [T3].[bird_soccer_role_id] INNER JOIN [bird_soccer_match] AS [T4] ON [T2].[bird_soccer_match_id] = [T4].[bird_soccer_match_id] WHERE [T1].[bird_soccer_player_name] = 'SC Ganguly' AND [T4].[bird_soccer_match_date] = '2008-04-18';

-- question_id=15 source_index=1802
SELECT MAX([T3].[bird_soccer_win_margin]) FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_player_match] AS [T2] ON [T1].[bird_soccer_player_id] = [T2].[bird_soccer_player_id] INNER JOIN [bird_soccer_match] AS [T3] ON [T2].[bird_soccer_match_id] = [T3].[bird_soccer_match_id] WHERE [T1].[bird_soccer_player_name] = 'SC Ganguly';

-- question_id=16 source_index=1803
SELECT CAST(SUM([T3].[bird_soccer_win_margin]) AS FLOAT) / NULLIF(COUNT(*), 0) FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_player_match] AS [T2] ON [T1].[bird_soccer_player_id] = [T2].[bird_soccer_player_id] INNER JOIN [bird_soccer_match] AS [T3] ON [T2].[bird_soccer_match_id] = [T3].[bird_soccer_match_id] WHERE [T1].[bird_soccer_player_name] = 'SC Ganguly';

-- question_id=17 source_index=1804
SELECT CAST(SUM(CASE WHEN [T2].[bird_soccer_batting_hand] = 'Right-hand bat' THEN 1 ELSE 0 END) AS FLOAT) * 100 / NULLIF(COUNT([T1].[bird_soccer_player_id]), 0) FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_batting_style] AS [T2] ON [T1].[bird_soccer_batting_hand] = [T2].[bird_soccer_batting_id] WHERE DATEPART(year, [T1].[bird_soccer_dob]) > 1985;

-- question_id=18 source_index=1805
SELECT TOP 1 [bird_soccer_player_name] FROM [bird_soccer_player] ORDER BY [bird_soccer_dob] DESC;

-- question_id=19 source_index=1806
SELECT SUM(CASE WHEN [bird_soccer_toss_winner] = [bird_soccer_team_id] THEN 1 ELSE 0 END) FROM [bird_soccer_match] CROSS JOIN [bird_soccer_team] WHERE [bird_soccer_team_name] = 'Sunrisers Hyderabad';

-- question_id=20 source_index=1807
SELECT [T2].[bird_soccer_player_name] FROM [bird_soccer_ball_by_ball] AS [T1] INNER JOIN [bird_soccer_player] AS [T2] ON [T1].[bird_soccer_striker] = [T2].[bird_soccer_player_id] WHERE [T1].[bird_soccer_match_id] = 419169 AND [T1].[bird_soccer_over_id] = 3 AND [T1].[bird_soccer_ball_id] = 2 AND [T1].[bird_soccer_innings_no] = 2;

-- question_id=21 source_index=1808
SELECT [T2].[bird_soccer_venue_name] FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_venue] AS [T2] ON [T1].[bird_soccer_venue_id] = [T2].[bird_soccer_venue_id] WHERE [T1].[bird_soccer_win_margin] = 138;

-- question_id=22 source_index=1809
SELECT [T1].[bird_soccer_player_name] FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_match] AS [T2] ON [T1].[bird_soccer_player_id] = [T2].[bird_soccer_man_of_the_match] WHERE [T2].[bird_soccer_match_date] = '2008-05-12';

-- question_id=23 source_index=1810
SELECT [T3].[bird_soccer_player_name] FROM [bird_soccer_player_match] AS [T1] INNER JOIN [bird_soccer_rolee] AS [T2] ON [T1].[bird_soccer_role_id] = [T2].[bird_soccer_role_id] INNER JOIN [bird_soccer_player] AS [T3] ON [T1].[bird_soccer_player_id] = [T3].[bird_soccer_player_id] WHERE [T1].[bird_soccer_match_id] = '419117' AND [T2].[bird_soccer_role_desc] = 'CaptainKeeper';

-- question_id=24 source_index=1811
SELECT [T2].[bird_soccer_player_name] FROM [bird_soccer_season] AS [T1] INNER JOIN [bird_soccer_player] AS [T2] ON [T1].[bird_soccer_man_of_the_series] = [T2].[bird_soccer_player_id] WHERE [T1].[bird_soccer_season_year] = 2013;

-- question_id=25 source_index=1812
SELECT [T2].[bird_soccer_dob] FROM [bird_soccer_season] AS [T1] INNER JOIN [bird_soccer_player] AS [T2] ON [T1].[bird_soccer_man_of_the_series] = [T2].[bird_soccer_player_id] WHERE [T1].[bird_soccer_season_year] = 2014 AND NOT [T1].[bird_soccer_orange_cap] IS NULL;

-- question_id=26 source_index=1813
SELECT [T3].[bird_soccer_country_name] FROM [bird_soccer_season] AS [T1] INNER JOIN [bird_soccer_player] AS [T2] ON [T1].[bird_soccer_man_of_the_series] = [T2].[bird_soccer_player_id] INNER JOIN [bird_soccer_country] AS [T3] ON [T2].[bird_soccer_country_name] = [T3].[bird_soccer_country_id] WHERE [T1].[bird_soccer_season_id] = 7 AND NOT [T1].[bird_soccer_purple_cap] IS NULL;

-- question_id=27 source_index=1814
SELECT [T2].[bird_soccer_country_name] FROM [bird_soccer_city] AS [T1] INNER JOIN [bird_soccer_country] AS [T2] ON [T1].[bird_soccer_country_id] = [T2].[bird_soccer_country_id] WHERE [T1].[bird_soccer_city_name] = 'Ranchi';

-- question_id=28 source_index=1815
SELECT SUM(CASE WHEN [T2].[bird_soccer_country_name] = 'India' THEN 1 ELSE 0 END) FROM [bird_soccer_city] AS [T1] INNER JOIN [bird_soccer_country] AS [T2] ON [T1].[bird_soccer_country_id] = [T2].[bird_soccer_country_id];

-- question_id=29 source_index=1816
SELECT TOP 1 [T1].[bird_soccer_city_name] FROM [bird_soccer_city] AS [T1] INNER JOIN [bird_soccer_venue] AS [T2] ON [T1].[bird_soccer_city_id] = [T2].[bird_soccer_city_id] GROUP BY [T1].[bird_soccer_city_id], [T1].[bird_soccer_city_name] ORDER BY COUNT([T2].[bird_soccer_venue_id]) DESC;

-- question_id=30 source_index=1817
SELECT [T2].[bird_soccer_batting_hand] FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_batting_style] AS [T2] ON [T1].[bird_soccer_batting_hand] = [T2].[bird_soccer_batting_id] WHERE [T1].[bird_soccer_player_name] = 'MK Pandey';

-- question_id=31 source_index=1818
SELECT CAST(SUM(CASE WHEN [T2].[bird_soccer_country_name] = 'India' THEN 1 ELSE 0 END) AS FLOAT) / NULLIF(SUM(CASE WHEN [T2].[bird_soccer_country_name] = 'South Africa' THEN 1 ELSE 0 END), 0) FROM [bird_soccer_city] AS [T1] INNER JOIN [bird_soccer_country] AS [T2] ON [T1].[bird_soccer_country_id] = [T2].[bird_soccer_country_id];

-- question_id=32 source_index=1819
SELECT SUM(CASE WHEN [T2].[bird_soccer_venue_name] = 'M Chinnaswamy Stadium' THEN 1 ELSE 0 END) - SUM(CASE WHEN [T2].[bird_soccer_venue_name] = 'Maharashtra Cricket Association Stadium' THEN 1 ELSE 0 END) FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_venue] AS [T2] ON [T1].[bird_soccer_venue_id] = [T2].[bird_soccer_venue_id];

-- question_id=33 source_index=1820
SELECT TOP 1 [bird_soccer_player_name] FROM [bird_soccer_player] ORDER BY [bird_soccer_dob] ASC;

-- question_id=34 source_index=1821
SELECT SUM(CASE WHEN DATEPART(month, [bird_soccer_match_date]) = '5' THEN 1 ELSE 0 END) FROM [bird_soccer_match] WHERE DATEPART(year, [bird_soccer_match_date]) = '2008';

-- question_id=35 source_index=1822
SELECT COUNT([bird_soccer_player_id]) AS [cnt] FROM [bird_soccer_player] WHERE [bird_soccer_dob] BETWEEN '1990-01-01' AND '1999-12-31';

-- question_id=36 source_index=1823
SELECT SUM(CASE WHEN [bird_soccer_team_1] = 10 OR [bird_soccer_team_2] = 10 THEN 1 ELSE 0 END) FROM [bird_soccer_match] WHERE DATEPART(year, [bird_soccer_match_date]) = '2012';

-- question_id=37 source_index=1824
SELECT [bird_soccer_orange_cap] FROM [bird_soccer_season] GROUP BY [bird_soccer_orange_cap] HAVING COUNT([bird_soccer_season_year]) > 1;

-- question_id=38 source_index=1825
SELECT COUNT([bird_soccer_match_id]) FROM [bird_soccer_match] WHERE [bird_soccer_season_id] = 7;

-- question_id=39 source_index=1826
SELECT SUM(CASE WHEN [T1].[bird_soccer_country_name] = 'South Africa' THEN 1 ELSE 0 END) FROM [bird_soccer_country] AS [T1] INNER JOIN [bird_soccer_umpire] AS [T2] ON [T1].[bird_soccer_country_id] = [T2].[bird_soccer_umpire_country];

-- question_id=40 source_index=1827
SELECT TOP 1 [T1].[bird_soccer_player_name] FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_match] AS [T2] ON [T1].[bird_soccer_player_id] = [T2].[bird_soccer_man_of_the_match] GROUP BY [T2].[bird_soccer_man_of_the_match], [T1].[bird_soccer_player_name] ORDER BY COUNT([T2].[bird_soccer_man_of_the_match]) DESC;

-- question_id=41 source_index=1828
SELECT TOP 1 [T1].[bird_soccer_country_name] FROM [bird_soccer_country] AS [T1] INNER JOIN [bird_soccer_player] AS [T2] ON [T1].[bird_soccer_country_id] = [T2].[bird_soccer_country_name] GROUP BY [T2].[bird_soccer_country_name], [T1].[bird_soccer_country_name] ORDER BY COUNT([T2].[bird_soccer_country_name]) DESC;

-- question_id=42 source_index=1829
SELECT SUM(CASE WHEN [T1].[bird_soccer_player_name] = 'CH Gayle' THEN 1 ELSE 0 END) AS [cnt] FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_season] AS [T2] ON [T1].[bird_soccer_player_id] = [T2].[bird_soccer_orange_cap];

-- question_id=43 source_index=1830
SELECT TOP 1 [T1].[bird_soccer_season_id] FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_venue] AS [T2] ON [T1].[bird_soccer_venue_id] = [T2].[bird_soccer_venue_id] WHERE [T2].[bird_soccer_venue_name] = 'M Chinnaswamy Stadium' GROUP BY [T1].[bird_soccer_season_id] ORDER BY COUNT([T1].[bird_soccer_season_id]) DESC;

-- question_id=44 source_index=1831
SELECT [bird_soccer_team_name] FROM [bird_soccer_team] WHERE [bird_soccer_team_id] = (SELECT TOP 1 [bird_soccer_match_winner] FROM [bird_soccer_match] WHERE [bird_soccer_season_id] = 1 GROUP BY [bird_soccer_match_winner] ORDER BY COUNT([bird_soccer_match_winner]) DESC) GROUP BY [bird_soccer_team_name];

-- question_id=45 source_index=1832
SELECT TOP 1 [T3].[bird_soccer_venue_name] FROM [bird_soccer_team] AS [T1] INNER JOIN [bird_soccer_match] AS [T2] ON [T1].[bird_soccer_team_id] = [T2].[bird_soccer_team_1] INNER JOIN [bird_soccer_venue] AS [T3] ON [T2].[bird_soccer_venue_id] = [T3].[bird_soccer_venue_id] WHERE [T1].[bird_soccer_team_name] = 'Kolkata Knight Riders' GROUP BY [T3].[bird_soccer_venue_id], [T3].[bird_soccer_venue_name] ORDER BY COUNT([T3].[bird_soccer_venue_id]) DESC;

-- question_id=46 source_index=1833
SELECT [T1].[bird_soccer_team_name] FROM [bird_soccer_team] AS [T1] INNER JOIN (SELECT TOP 1 * FROM (SELECT COUNT([bird_soccer_team_1]) AS [a], [bird_soccer_team_1] FROM [bird_soccer_match] WHERE [bird_soccer_team_1] <> [bird_soccer_match_winner] GROUP BY [bird_soccer_team_1] UNION SELECT COUNT([bird_soccer_team_2]) AS [a], [bird_soccer_team_2] FROM [bird_soccer_match] WHERE [bird_soccer_team_2] <> [bird_soccer_match_winner] GROUP BY [bird_soccer_team_2]) AS [_l_0] ORDER BY [a] DESC) AS [T2] ON [T1].[bird_soccer_team_id] = [T2].[bird_soccer_team_1] GROUP BY [T1].[bird_soccer_team_name];

-- question_id=47 source_index=1834
SELECT [bird_soccer_player_name] FROM [bird_soccer_player] WHERE [bird_soccer_player_id] = (SELECT TOP 1 [bird_soccer_man_of_the_match] FROM [bird_soccer_match] ORDER BY [bird_soccer_match_date] ASC);

-- question_id=48 source_index=1835
SELECT TOP 1 [bird_soccer_match_date] FROM [bird_soccer_match] WHERE [bird_soccer_team_1] = (SELECT [bird_soccer_team_id] FROM [bird_soccer_team] WHERE [bird_soccer_team_name] = 'Chennai Super Kings') OR [bird_soccer_team_2] = (SELECT [bird_soccer_team_id] FROM [bird_soccer_team] WHERE [bird_soccer_team_name] = 'Chennai Super Kings') ORDER BY [bird_soccer_match_date] ASC;

-- question_id=49 source_index=1836
SELECT SUM(CASE WHEN [T1].[bird_soccer_batting_hand] = 'Left-hand bat' THEN 1 ELSE 0 END) AS [cnt] FROM [bird_soccer_batting_style] AS [T1] INNER JOIN [bird_soccer_player] AS [T2] ON [T1].[bird_soccer_batting_id] = [T2].[bird_soccer_batting_hand] INNER JOIN [bird_soccer_country] AS [T3] ON [T2].[bird_soccer_country_name] = [T3].[bird_soccer_country_id] WHERE [T3].[bird_soccer_country_name] = 'India';

-- question_id=50 source_index=1837
SELECT TOP 1 [T4].[bird_soccer_player_name] FROM [bird_soccer_team] AS [T1] INNER JOIN [bird_soccer_player_match] AS [T2] ON [T1].[bird_soccer_team_id] = [T2].[bird_soccer_team_id] INNER JOIN [bird_soccer_rolee] AS [T3] ON [T2].[bird_soccer_role_id] = [T3].[bird_soccer_role_id] INNER JOIN [bird_soccer_player] AS [T4] ON [T2].[bird_soccer_player_id] = [T4].[bird_soccer_player_id] WHERE [T1].[bird_soccer_team_name] = 'Deccan Chargers' AND [T1].[bird_soccer_team_id] = 8 AND [T3].[bird_soccer_role_desc] = 'Captain' AND [T3].[bird_soccer_role_id] = 1 GROUP BY [T4].[bird_soccer_player_id], [T4].[bird_soccer_player_name] ORDER BY COUNT([T3].[bird_soccer_role_id]) DESC;

-- question_id=51 source_index=1838
SELECT CAST(SUM(CASE WHEN [T1].[bird_soccer_batting_hand] = 'Right-hand bat' THEN 1 ELSE 0 END) AS FLOAT) * 100 / NULLIF(COUNT([T2].[bird_soccer_player_id]), 0) FROM [bird_soccer_batting_style] AS [T1] INNER JOIN [bird_soccer_player] AS [T2] ON [T2].[bird_soccer_batting_hand] = [T1].[bird_soccer_batting_id];

-- question_id=52 source_index=1839
SELECT [bird_soccer_player_name] FROM [bird_soccer_player] WHERE [bird_soccer_dob] = '1981-07-07';

-- question_id=53 source_index=1840
SELECT SUM(CASE WHEN [bird_soccer_player_id] = 2 THEN 1 ELSE 0 END) FROM [bird_soccer_player_match];

-- question_id=54 source_index=1841
SELECT TOP 1 [T2].[bird_soccer_team_name] FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_team] AS [T2] ON [T2].[bird_soccer_team_id] = [T1].[bird_soccer_team_1] ORDER BY [T1].[bird_soccer_win_margin] DESC;

-- question_id=55 source_index=1842
SELECT [T3].[bird_soccer_country_name] FROM [bird_soccer_venue] AS [T1] INNER JOIN [bird_soccer_city] AS [T2] ON [T2].[bird_soccer_city_id] = [T1].[bird_soccer_city_id] INNER JOIN [bird_soccer_country] AS [T3] ON [T3].[bird_soccer_country_id] = [T2].[bird_soccer_country_id] WHERE [T1].[bird_soccer_venue_name] = 'St George''s Park';

-- question_id=56 source_index=1843
SELECT [T3].[bird_soccer_team_name] FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_player_match] AS [T2] ON [T2].[bird_soccer_player_id] = [T1].[bird_soccer_player_id] INNER JOIN [bird_soccer_team] AS [T3] ON [T3].[bird_soccer_team_id] = [T2].[bird_soccer_team_id] WHERE [T2].[bird_soccer_match_id] = 335990 AND [T3].[bird_soccer_team_name] = 'Mumbai Indians' GROUP BY [T3].[bird_soccer_team_name];

-- question_id=57 source_index=1844
SELECT [T1].[bird_soccer_team_name] FROM [bird_soccer_team] AS [T1] INNER JOIN [bird_soccer_match] AS [T2] ON [T1].[bird_soccer_team_id] = [T2].[bird_soccer_match_winner] WHERE [T2].[bird_soccer_match_date] = '2009-05-07' AND [T2].[bird_soccer_win_margin] = 7;

-- question_id=58 source_index=1845
SELECT SUM(CASE WHEN [T2].[bird_soccer_outcome_type] = 'Superover' THEN 1 ELSE 0 END) FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_outcome] AS [T2] ON [T2].[bird_soccer_outcome_id] = [T1].[bird_soccer_outcome_type];

-- question_id=59 source_index=1846
SELECT [T1].[bird_soccer_city_name] FROM [bird_soccer_city] AS [T1] INNER JOIN [bird_soccer_country] AS [T2] ON [T2].[bird_soccer_country_id] = [T1].[bird_soccer_country_id] WHERE [T2].[bird_soccer_country_name] = 'U.A.E';

-- question_id=60 source_index=1847
SELECT SUM(CASE WHEN [T2].[bird_soccer_team_name] = 'Pune Warriors' THEN 1 ELSE 0 END) FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_team] AS [T2] ON [T2].[bird_soccer_team_id] = [T1].[bird_soccer_match_winner];

-- question_id=61 source_index=1848
SELECT [T2].[bird_soccer_team_name] FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_team] AS [T2] ON [T2].[bird_soccer_team_id] = [T1].[bird_soccer_match_winner] WHERE [T1].[bird_soccer_match_date] LIKE '2015%' AND [T1].[bird_soccer_match_id] = 829768;

-- question_id=62 source_index=1849
SELECT [T3].[bird_soccer_role_desc] FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_player_match] AS [T2] ON [T2].[bird_soccer_player_id] = [T1].[bird_soccer_player_id] INNER JOIN [bird_soccer_rolee] AS [T3] ON [T3].[bird_soccer_role_id] = [T2].[bird_soccer_role_id] WHERE [T2].[bird_soccer_match_id] = 335992 AND [T1].[bird_soccer_player_name] = 'K Goel';

-- question_id=63 source_index=1850
SELECT SUM(CASE WHEN [T2].[bird_soccer_country_name] = 'South Africa' THEN 1 ELSE 0 END) FROM [bird_soccer_city] AS [T1] INNER JOIN [bird_soccer_country] AS [T2] ON [T2].[bird_soccer_country_id] = [T1].[bird_soccer_country_id];

-- question_id=64 source_index=1851
SELECT SUM(CASE WHEN [T2].[bird_soccer_venue_name] = 'Newlands' THEN 1 ELSE 0 END) FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_venue] AS [T2] ON [T2].[bird_soccer_venue_id] = [T1].[bird_soccer_venue_id];

-- question_id=65 source_index=1852
SELECT [T1].[bird_soccer_win_margin] FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_team] AS [T2] ON [T2].[bird_soccer_team_id] = [T1].[bird_soccer_team_1] INNER JOIN [bird_soccer_team] AS [T3] ON [T3].[bird_soccer_team_id] = [T1].[bird_soccer_team_2] WHERE ([T2].[bird_soccer_team_name] = 'Mumbai Indians' AND [T3].[bird_soccer_team_name] = 'Royal Challengers Bangalore' AND [T1].[bird_soccer_match_date] = '2008-05-28') OR ([T2].[bird_soccer_team_name] = 'Royal Challengers Bangalore' AND [T3].[bird_soccer_team_name] = 'Mumbai Indians' AND [T1].[bird_soccer_match_date] = '2008-05-28');

-- question_id=66 source_index=1853
SELECT DISTINCT CASE WHEN [T1].[bird_soccer_win_margin] < (SELECT AVG([bird_soccer_win_margin]) * 0.3 FROM [bird_soccer_match] WHERE [bird_soccer_match_date] LIKE '2011%') THEN [T2].[bird_soccer_team_name] END, CASE WHEN [T1].[bird_soccer_win_margin] < (SELECT AVG([bird_soccer_win_margin]) * 0.3 FROM [bird_soccer_match] WHERE [bird_soccer_match_date] LIKE '2011%') THEN [T3].[bird_soccer_team_name] END FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_team] AS [T2] ON [T2].[bird_soccer_team_id] = [T1].[bird_soccer_team_1] INNER JOIN [bird_soccer_team] AS [T3] ON [T3].[bird_soccer_team_id] = [T1].[bird_soccer_team_2] WHERE [T1].[bird_soccer_match_date] LIKE '2011%' GROUP BY [T1].[bird_soccer_win_margin], [bird_soccer_match_date], [T2].[bird_soccer_team_name], [T3].[bird_soccer_team_name];

-- question_id=67 source_index=1854
SELECT CAST(SUM(CASE WHEN [T1].[bird_soccer_role_desc] = 'Captain' THEN 1 ELSE 0 END) AS FLOAT) * 100 / NULLIF(COUNT([T1].[bird_soccer_role_id]), 0) FROM [bird_soccer_rolee] AS [T1] INNER JOIN [bird_soccer_player_match] AS [T2] ON [T2].[bird_soccer_role_id] = [T1].[bird_soccer_role_id] INNER JOIN [bird_soccer_player] AS [T3] ON [T3].[bird_soccer_player_id] = [T2].[bird_soccer_player_id] WHERE [T3].[bird_soccer_dob] LIKE '1977%';

-- question_id=68 source_index=1855
SELECT COUNT([bird_soccer_over_id]) FROM [bird_soccer_ball_by_ball] WHERE [bird_soccer_match_id] = 335996 AND [bird_soccer_innings_no] = 1;

-- question_id=69 source_index=1856
SELECT TOP 1 [bird_soccer_over_id], [bird_soccer_ball_id], [bird_soccer_innings_no] FROM [bird_soccer_batsman_scored] WHERE [bird_soccer_match_id] = 336004 ORDER BY [bird_soccer_runs_scored] DESC;

-- question_id=70 source_index=1857
SELECT TOP 5 [bird_soccer_match_id] FROM [bird_soccer_ball_by_ball] WHERE [bird_soccer_over_id] = 20 GROUP BY [bird_soccer_match_id];

-- question_id=71 source_index=1858
SELECT SUM(CASE WHEN [bird_soccer_match_id] = 548335 THEN 1 ELSE 0 END) FROM [bird_soccer_wicket_taken] WHERE [bird_soccer_innings_no] = 1;

-- question_id=72 source_index=1859
SELECT [bird_soccer_player_name] FROM [bird_soccer_player] WHERE [bird_soccer_dob] LIKE '1971%';

-- question_id=73 source_index=1860
SELECT [bird_soccer_match_id] FROM [bird_soccer_match] WHERE [bird_soccer_match_date] LIKE '%2015-04-18%';

-- question_id=74 source_index=1861
SELECT [T1].[bird_soccer_match_id] FROM [bird_soccer_wicket_taken] AS [T1] INNER JOIN [bird_soccer_out_type] AS [T2] ON [T2].[bird_soccer_out_id] = [T1].[bird_soccer_kind_out] WHERE [T2].[bird_soccer_out_name] = 'hit wicket';

-- question_id=75 source_index=1862
SELECT SUM(CASE WHEN [T1].[bird_soccer_innings_no] = 2 THEN 1 ELSE 0 END) FROM [bird_soccer_wicket_taken] AS [T1] INNER JOIN [bird_soccer_out_type] AS [T2] ON [T2].[bird_soccer_out_id] = [T1].[bird_soccer_kind_out] WHERE [T2].[bird_soccer_out_name] = 'stumped';

-- question_id=76 source_index=1863
SELECT SUM(CASE WHEN [T2].[bird_soccer_player_name] = 'Yuvraj Singh' THEN 1 ELSE 0 END) FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_player] AS [T2] ON [T2].[bird_soccer_player_id] = [T1].[bird_soccer_man_of_the_match];

-- question_id=77 source_index=1864
SELECT [T2].[bird_soccer_player_name], [T2].[bird_soccer_dob] FROM [bird_soccer_country] AS [T1] INNER JOIN [bird_soccer_player] AS [T2] ON [T2].[bird_soccer_country_name] = [T1].[bird_soccer_country_id] WHERE [T2].[bird_soccer_dob] LIKE '1977%' AND [T1].[bird_soccer_country_name] = 'England';

-- question_id=78 source_index=1865
SELECT [T1].[bird_soccer_player_name] FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_match] AS [T2] ON [T2].[bird_soccer_man_of_the_match] = [T1].[bird_soccer_player_id] INNER JOIN [bird_soccer_season] AS [T3] ON [T3].[bird_soccer_season_id] = [T2].[bird_soccer_season_id] WHERE [T3].[bird_soccer_season_year] = 2010 GROUP BY [T1].[bird_soccer_player_name];

-- question_id=79 source_index=1866
SELECT CAST(SUM(CASE WHEN [T1].[bird_soccer_match_winner] = 3 THEN 1 ELSE 0 END) AS FLOAT) * 100 / NULLIF(COUNT([T1].[bird_soccer_match_id]), 0) FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_team] AS [T2] ON [T2].[bird_soccer_team_id] = [T1].[bird_soccer_team_1] INNER JOIN [bird_soccer_team] AS [T3] ON [T3].[bird_soccer_team_id] = [T1].[bird_soccer_team_2] WHERE [T2].[bird_soccer_team_name] = 'Chennai Super Kings' OR [T3].[bird_soccer_team_name] = 'Chennai Super Kings';

-- question_id=80 source_index=1867
SELECT [T4].[bird_soccer_player_name], [T5].[bird_soccer_country_name] FROM [bird_soccer_player_match] AS [T1] INNER JOIN [bird_soccer_team] AS [T2] ON [T2].[bird_soccer_team_id] = [T1].[bird_soccer_team_id] INNER JOIN [bird_soccer_match] AS [T3] ON [T3].[bird_soccer_match_id] = [T1].[bird_soccer_match_id] INNER JOIN [bird_soccer_player] AS [T4] ON [T4].[bird_soccer_player_id] = [T1].[bird_soccer_player_id] INNER JOIN [bird_soccer_country] AS [T5] ON [T5].[bird_soccer_country_id] = [T4].[bird_soccer_country_name] WHERE [T2].[bird_soccer_team_name] = 'Gujarat Lions' AND [T3].[bird_soccer_match_date] = '2016-04-11';

-- question_id=81 source_index=1868
SELECT [T1].[bird_soccer_player_name], [T1].[bird_soccer_dob] FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_bowling_style] AS [T2] ON [T2].[bird_soccer_bowling_id] = [T1].[bird_soccer_bowling_skill] WHERE [T2].[bird_soccer_bowling_skill] = 'Left-arm fast';

-- question_id=82 source_index=1869
SELECT [T1].[bird_soccer_country_name] FROM [bird_soccer_country] AS [T1] INNER JOIN [bird_soccer_umpire] AS [T2] ON [T2].[bird_soccer_umpire_country] = [T1].[bird_soccer_country_id] WHERE [T2].[bird_soccer_umpire_name] = 'BR Doctrove';

-- question_id=83 source_index=1870
SELECT [T3].[bird_soccer_player_name] FROM [bird_soccer_player_match] AS [T1] INNER JOIN [bird_soccer_match] AS [T2] ON [T2].[bird_soccer_match_id] = [T1].[bird_soccer_match_id] INNER JOIN [bird_soccer_player] AS [T3] ON [T3].[bird_soccer_player_id] = [T1].[bird_soccer_player_id] INNER JOIN [bird_soccer_rolee] AS [T4] ON [T4].[bird_soccer_role_id] = [T1].[bird_soccer_role_id] WHERE [T2].[bird_soccer_match_date] = '2008-06-01' AND [T4].[bird_soccer_role_desc] = 'Captain' AND [T2].[bird_soccer_match_winner] = [T1].[bird_soccer_team_id];

-- question_id=84 source_index=1871
SELECT [T3].[bird_soccer_team_name], COUNT([T2].[bird_soccer_match_id]) FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_player_match] AS [T2] ON [T2].[bird_soccer_player_id] = [T1].[bird_soccer_player_id] INNER JOIN [bird_soccer_team] AS [T3] ON [T3].[bird_soccer_team_id] = [T2].[bird_soccer_team_id] WHERE [T1].[bird_soccer_player_name] = 'CK Kapugedera' GROUP BY [T3].[bird_soccer_team_name];

-- question_id=85 source_index=1872
SELECT CAST(SUM(CASE WHEN [T2].[bird_soccer_venue_name] = 'Wankhede Stadium' THEN 1 ELSE 0 END) AS FLOAT) * 100 / NULLIF(COUNT([T3].[bird_soccer_match_id]), 0) FROM [bird_soccer_city] AS [T1] INNER JOIN [bird_soccer_venue] AS [T2] ON [T2].[bird_soccer_city_id] = [T1].[bird_soccer_city_id] INNER JOIN [bird_soccer_match] AS [T3] ON [T3].[bird_soccer_venue_id] = [T2].[bird_soccer_venue_id] WHERE [T1].[bird_soccer_city_name] = 'Mumbai';

-- question_id=86 source_index=1873
SELECT CAST(SUM(CASE WHEN [T2].[bird_soccer_out_name] = 'bowled' THEN 1 ELSE 0 END) AS FLOAT) * 100 / NULLIF(COUNT([T1].[bird_soccer_player_out]), 0) FROM [bird_soccer_wicket_taken] AS [T1] INNER JOIN [bird_soccer_out_type] AS [T2] ON [T2].[bird_soccer_out_id] = [T1].[bird_soccer_kind_out] WHERE [T1].[bird_soccer_match_id] = 392187;

-- question_id=87 source_index=1874
SELECT CAST(SUM(CASE WHEN [T2].[bird_soccer_toss_name] = 'field' THEN 1 ELSE 0 END) AS FLOAT) * 100 / NULLIF(COUNT([T2].[bird_soccer_toss_id]), 0) FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_toss_decision] AS [T2] ON [T2].[bird_soccer_toss_id] = [T1].[bird_soccer_toss_decide] WHERE [T1].[bird_soccer_match_date] BETWEEN '2010-01-01' AND '2016-12-31';

-- question_id=88 source_index=1875
SELECT [bird_soccer_toss_winner] FROM [bird_soccer_match] WHERE [bird_soccer_toss_decide] = 2;

-- question_id=89 source_index=1876
SELECT [T1].[bird_soccer_match_id] FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_player] AS [T2] ON [T2].[bird_soccer_player_id] = [T1].[bird_soccer_man_of_the_match] WHERE [T2].[bird_soccer_player_name] = 'BB McCullum';

-- question_id=90 source_index=1877
SELECT [T2].[bird_soccer_dob] FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_player] AS [T2] ON [T2].[bird_soccer_player_id] = [T1].[bird_soccer_man_of_the_match];

-- question_id=91 source_index=1878
SELECT [T2].[bird_soccer_team_name] FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_team] AS [T2] ON [T2].[bird_soccer_team_id] = [T1].[bird_soccer_toss_winner] WHERE [T1].[bird_soccer_match_id] BETWEEN 336010 AND 336020;

-- question_id=92 source_index=1879
SELECT SUM(CASE WHEN [T2].[bird_soccer_team_name] = 'Mumbai Indians' THEN 1 ELSE 0 END) FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_team] AS [T2] ON [T2].[bird_soccer_team_id] = [T1].[bird_soccer_match_winner];

-- question_id=93 source_index=1880
SELECT [T2].[bird_soccer_team_name] FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_team] AS [T2] ON [T2].[bird_soccer_team_id] = [T1].[bird_soccer_team_2] WHERE [T1].[bird_soccer_team_1] = (SELECT [bird_soccer_team_id] FROM [bird_soccer_team] WHERE [bird_soccer_team_name] = 'Pune Warriors') GROUP BY [T2].[bird_soccer_team_name];

-- question_id=94 source_index=1881
SELECT [T2].[bird_soccer_team_name] FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_team] AS [T2] ON [T2].[bird_soccer_team_id] = [T1].[bird_soccer_match_winner] WHERE [T1].[bird_soccer_match_id] = 336000;

-- question_id=95 source_index=1882
SELECT [T1].[bird_soccer_match_id] FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_venue] AS [T2] ON [T2].[bird_soccer_venue_id] = [T1].[bird_soccer_venue_id] WHERE [T2].[bird_soccer_venue_name] = 'Brabourne Stadium';

-- question_id=96 source_index=1883
SELECT [T2].[bird_soccer_venue_name] FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_venue] AS [T2] ON [T2].[bird_soccer_venue_id] = [T1].[bird_soccer_venue_id] WHERE [T1].[bird_soccer_season_id] = 2 GROUP BY [T2].[bird_soccer_venue_name];

-- question_id=97 source_index=1884
SELECT [T1].[bird_soccer_city_name] FROM [bird_soccer_city] AS [T1] INNER JOIN [bird_soccer_venue] AS [T2] ON [T2].[bird_soccer_city_id] = [T1].[bird_soccer_city_id] WHERE [T2].[bird_soccer_venue_name] = 'M Chinnaswamy Stadium';

-- question_id=98 source_index=1885
SELECT [T2].[bird_soccer_venue_name] FROM [bird_soccer_city] AS [T1] INNER JOIN [bird_soccer_venue] AS [T2] ON [T2].[bird_soccer_city_id] = [T1].[bird_soccer_city_id] WHERE [T1].[bird_soccer_city_name] = 'Mumbai';

-- question_id=99 source_index=1886
SELECT [T2].[bird_soccer_match_winner] FROM [bird_soccer_venue] AS [T1] INNER JOIN [bird_soccer_match] AS [T2] ON [T1].[bird_soccer_venue_id] = [T2].[bird_soccer_venue_id] WHERE [T1].[bird_soccer_venue_name] LIKE 'St George%';

-- question_id=100 source_index=1887
SELECT [T2].[bird_soccer_city_name] FROM [bird_soccer_venue] AS [T1] INNER JOIN [bird_soccer_city] AS [T2] ON [T1].[bird_soccer_city_id] = [T2].[bird_soccer_city_id] WHERE [T1].[bird_soccer_venue_name] LIKE 'St George%';

-- question_id=101 source_index=1888
SELECT SUM([T2].[bird_soccer_match_winner]) FROM [bird_soccer_team] AS [T1] INNER JOIN [bird_soccer_match] AS [T2] ON [T1].[bird_soccer_team_id] = [T2].[bird_soccer_match_winner] WHERE [T1].[bird_soccer_team_name] = 'Deccan Chargers';

-- question_id=102 source_index=1889
SELECT COUNT([T1].[bird_soccer_venue_name]) FROM [bird_soccer_venue] AS [T1] INNER JOIN [bird_soccer_city] AS [T2] ON [T1].[bird_soccer_city_id] = [T2].[bird_soccer_city_id] WHERE [T2].[bird_soccer_city_name] = 'Pune';

-- question_id=103 source_index=1890
SELECT TOP 1 [bird_soccer_ball_id] FROM [bird_soccer_ball_by_ball] WHERE [bird_soccer_non_striker] = [bird_soccer_ball_id] ORDER BY [bird_soccer_ball_id] DESC;

-- question_id=104 source_index=1891
SELECT CAST(SUM(CASE WHEN 1 < [bird_soccer_over_id] AND [bird_soccer_over_id] < 25 THEN 1 ELSE 0 END) AS FLOAT) * 100 / NULLIF(SUM([bird_soccer_runs_scored]), 0) FROM [bird_soccer_batsman_scored] WHERE [bird_soccer_innings_no] = 1;

-- question_id=105 source_index=1892
SELECT AVG([bird_soccer_innings_no]) FROM [bird_soccer_extra_runs] WHERE [bird_soccer_innings_no] = 2;

-- question_id=106 source_index=1893
SELECT CAST(COUNT(CASE WHEN [bird_soccer_win_margin] > 100 THEN 1 ELSE 0 END) AS FLOAT) * 100 / NULLIF(SUM([bird_soccer_match_id]), 0) FROM [bird_soccer_match];

-- question_id=107 source_index=1894
SELECT [bird_soccer_player_name] FROM [bird_soccer_player] WHERE [bird_soccer_dob] BETWEEN '1970-01-01' AND '1990-12-31' ORDER BY [bird_soccer_dob] DESC;

-- question_id=108 source_index=1895
SELECT SUM(CASE WHEN [bird_soccer_fielders] = '' THEN 1 ELSE 0 END) FROM [bird_soccer_wicket_taken] WHERE [bird_soccer_over_id] = 3;

-- question_id=109 source_index=1896
SELECT TOP 1 [T2].[bird_soccer_country_id], COUNT([T1].[bird_soccer_umpire_id]) FROM [bird_soccer_umpire] AS [T1] INNER JOIN [bird_soccer_country] AS [T2] ON [T2].[bird_soccer_country_id] = [T1].[bird_soccer_umpire_country] GROUP BY [T2].[bird_soccer_country_id] ORDER BY COUNT([T1].[bird_soccer_umpire_id]) DESC;

-- question_id=110 source_index=1897
SELECT CAST(SUM(CASE WHEN [T2].[bird_soccer_role_desc] = 'CaptainKeeper' THEN 1 ELSE 0 END) AS FLOAT) * 100 / NULLIF(SUM([T1].[bird_soccer_player_id]), 0) FROM [bird_soccer_player_match] AS [T1] INNER JOIN [bird_soccer_rolee] AS [T2] ON [T1].[bird_soccer_role_id] = [T2].[bird_soccer_role_id];

-- question_id=111 source_index=1898
SELECT [bird_soccer_player_out] FROM [bird_soccer_wicket_taken] AS [T1] INNER JOIN [bird_soccer_out_type] AS [T2] ON [T1].[bird_soccer_kind_out] = [T2].[bird_soccer_out_id] WHERE [bird_soccer_out_name] = 'hit wicket';

-- question_id=112 source_index=1899
SELECT CAST(SUM(CASE WHEN [T1].[bird_soccer_batting_hand] = 'Right-hand bat' THEN 1 ELSE 0 END) AS FLOAT) * 100 / NULLIF(COUNT([T2].[bird_soccer_country_name]), 0) FROM [bird_soccer_batting_style] AS [T1] INNER JOIN [bird_soccer_player] AS [T2] ON [T1].[bird_soccer_batting_id] = [T2].[bird_soccer_batting_hand];

-- question_id=113 source_index=1900
SELECT CAST(SUM(CASE WHEN [T2].[bird_soccer_bowling_skill] = ' Legbreak' THEN 1 ELSE 0 END) AS FLOAT) * 100 / NULLIF(SUM([T1].[bird_soccer_player_id]), 0) FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_bowling_style] AS [T2] ON [T1].[bird_soccer_bowling_skill] = [T2].[bird_soccer_bowling_id];

-- question_id=114 source_index=1901
SELECT COUNT([T2].[bird_soccer_win_id]) FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_win_by] AS [T2] ON [T1].[bird_soccer_win_type] = [T2].[bird_soccer_win_id] WHERE [T2].[bird_soccer_win_type] = 'wickets' AND [T1].[bird_soccer_win_margin] < 50;

-- question_id=115 source_index=1902
SELECT SUM(CASE WHEN [T1].[bird_soccer_team_2] = [T1].[bird_soccer_match_winner] THEN 1 ELSE 0 END) FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_venue] AS [T2] ON [T1].[bird_soccer_venue_id] = [T2].[bird_soccer_venue_id] WHERE [T1].[bird_soccer_team_1] = [T1].[bird_soccer_toss_winner];

-- question_id=116 source_index=1903
SELECT [T2].[bird_soccer_player_name], [T3].[bird_soccer_country_name] FROM [bird_soccer_season] AS [T1] INNER JOIN [bird_soccer_player] AS [T2] ON [T1].[bird_soccer_man_of_the_series] = [T2].[bird_soccer_player_id] INNER JOIN [bird_soccer_country] AS [T3] ON [T2].[bird_soccer_country_name] = [T3].[bird_soccer_country_id] WHERE [T1].[bird_soccer_season_year] = 2012;

-- question_id=117 source_index=1904
SELECT TOP 1 [T2].[bird_soccer_venue_name] FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_venue] AS [T2] ON [T1].[bird_soccer_venue_id] = [T2].[bird_soccer_venue_id] GROUP BY [T2].[bird_soccer_venue_name] ORDER BY COUNT([T2].[bird_soccer_venue_id]) DESC;

-- question_id=118 source_index=1905
SELECT TOP 1 [T4].[bird_soccer_city_name] FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_win_by] AS [T2] ON [T1].[bird_soccer_win_type] = [T2].[bird_soccer_win_id] INNER JOIN [bird_soccer_venue] AS [T3] ON [T1].[bird_soccer_venue_id] = [T3].[bird_soccer_venue_id] INNER JOIN [bird_soccer_city] AS [T4] ON [T3].[bird_soccer_city_id] = [T4].[bird_soccer_city_id] WHERE [T2].[bird_soccer_win_type] = 'NO Result' GROUP BY [T4].[bird_soccer_city_id], [T4].[bird_soccer_city_name] ORDER BY COUNT([T2].[bird_soccer_win_type]) ASC;

-- question_id=119 source_index=1906
SELECT [T2].[bird_soccer_player_name] FROM [bird_soccer_season] AS [T1] INNER JOIN [bird_soccer_player] AS [T2] ON [T1].[bird_soccer_man_of_the_series] = [T2].[bird_soccer_player_id] WHERE [T1].[bird_soccer_man_of_the_series] > 1;

-- question_id=120 source_index=1907
SELECT [T1].[bird_soccer_player_name], [T4].[bird_soccer_country_name] FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_wicket_taken] AS [T2] ON [T1].[bird_soccer_player_id] = [T2].[bird_soccer_fielders] INNER JOIN [bird_soccer_out_type] AS [T3] ON [T2].[bird_soccer_kind_out] = [T3].[bird_soccer_out_id] INNER JOIN [bird_soccer_country] AS [T4] ON [T1].[bird_soccer_country_name] = [T4].[bird_soccer_country_id] GROUP BY [T1].[bird_soccer_player_name], [T4].[bird_soccer_country_name] ORDER BY COUNT([T3].[bird_soccer_out_name]) ASC;

-- question_id=121 source_index=1908
SELECT CAST(COUNT(CASE WHEN [T1].[bird_soccer_team_1] = [T1].[bird_soccer_match_winner] AND [T1].[bird_soccer_match_winner] = [T1].[bird_soccer_toss_winner] THEN 1 ELSE 0 END) AS FLOAT) * 100 / NULLIF(SUM([T1].[bird_soccer_team_1]), 0) FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_win_by] AS [T2] ON [T1].[bird_soccer_win_type] = [T2].[bird_soccer_win_id] INNER JOIN [bird_soccer_toss_decision] AS [T3] ON [T1].[bird_soccer_toss_decide] = [T3].[bird_soccer_toss_id] WHERE [T3].[bird_soccer_toss_name] = 'field' AND [T2].[bird_soccer_win_type] = 'runs';

-- question_id=122 source_index=1909
SELECT AVG([T1].[bird_soccer_player_out]) FROM [bird_soccer_wicket_taken] AS [T1] INNER JOIN [bird_soccer_out_type] AS [T2] ON [T1].[bird_soccer_kind_out] = [T2].[bird_soccer_out_id] WHERE [T2].[bird_soccer_out_name] = 'lbw';

-- question_id=123 source_index=1910
SELECT DISTINCT [bird_soccer_over_id] FROM [bird_soccer_ball_by_ball] WHERE [bird_soccer_striker] = 7;

-- question_id=124 source_index=1911
SELECT COUNT([bird_soccer_team_1]) FROM [bird_soccer_match] WHERE [bird_soccer_team_1] = [bird_soccer_toss_winner] AND [bird_soccer_toss_decide] = 2;

-- question_id=125 source_index=1912
SELECT SUM(CASE WHEN [bird_soccer_match_date] LIKE '2010-03%' THEN 1 ELSE 0 END) FROM [bird_soccer_match];

-- question_id=126 source_index=1913
SELECT SUM(CASE WHEN [bird_soccer_dob] < '1990-06-29' THEN 1 ELSE 0 END) FROM [bird_soccer_player] WHERE [bird_soccer_player_name] <> 'Gurkeerat Singh';

-- question_id=127 source_index=1914
SELECT SUM(CASE WHEN [T2].[bird_soccer_player_name] = 'SR Watson' THEN 1 ELSE 0 END) FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_player] AS [T2] ON [T1].[bird_soccer_man_of_the_match] = [T2].[bird_soccer_player_id];

-- question_id=128 source_index=1915
SELECT TOP 1 [T3].[bird_soccer_player_name] FROM [bird_soccer_player_match] AS [T1] INNER JOIN [bird_soccer_team] AS [T2] ON [T1].[bird_soccer_team_id] = [T2].[bird_soccer_team_id] INNER JOIN [bird_soccer_player] AS [T3] ON [T1].[bird_soccer_player_id] = [T3].[bird_soccer_player_id] WHERE [T2].[bird_soccer_team_name] = 'Delhi Daredevils' GROUP BY [T3].[bird_soccer_player_name] ORDER BY COUNT([T1].[bird_soccer_role_id]) DESC;

-- question_id=129 source_index=1916
SELECT TOP 1 [T3].[bird_soccer_player_name] FROM [bird_soccer_season] AS [T1] INNER JOIN [bird_soccer_match] AS [T2] ON [T1].[bird_soccer_man_of_the_series] = [T2].[bird_soccer_man_of_the_match] INNER JOIN [bird_soccer_player] AS [T3] ON [T2].[bird_soccer_man_of_the_match] = [T3].[bird_soccer_player_id] GROUP BY [T3].[bird_soccer_player_name] ORDER BY COUNT([T1].[bird_soccer_man_of_the_series]) DESC;

-- question_id=130 source_index=1917
SELECT [T4].[bird_soccer_season_year], [T4].[bird_soccer_orange_cap] FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_player_match] AS [T2] ON [T1].[bird_soccer_player_id] = [T2].[bird_soccer_player_id] INNER JOIN [bird_soccer_match] AS [T3] ON [T2].[bird_soccer_match_id] = [T3].[bird_soccer_match_id] INNER JOIN [bird_soccer_season] AS [T4] ON [T3].[bird_soccer_season_id] = [T4].[bird_soccer_season_id] WHERE [T1].[bird_soccer_player_name] = 'SP Narine' GROUP BY [T4].[bird_soccer_season_year], [T4].[bird_soccer_orange_cap];

-- question_id=131 source_index=1918
SELECT [T5].[bird_soccer_team_name], [T1].[bird_soccer_orange_cap], [T1].[bird_soccer_purple_cap] FROM [bird_soccer_season] AS [T1] INNER JOIN [bird_soccer_match] AS [T2] ON [T1].[bird_soccer_season_id] = [T2].[bird_soccer_season_id] INNER JOIN [bird_soccer_player_match] AS [T3] ON [T2].[bird_soccer_match_id] = [T3].[bird_soccer_match_id] INNER JOIN [bird_soccer_player] AS [T4] ON [T3].[bird_soccer_player_id] = [T4].[bird_soccer_player_id] INNER JOIN [bird_soccer_team] AS [T5] ON [T3].[bird_soccer_team_id] = [T5].[bird_soccer_team_id] GROUP BY [T5].[bird_soccer_team_name], [T1].[bird_soccer_orange_cap], [T1].[bird_soccer_purple_cap];

-- question_id=132 source_index=1919
SELECT [T1].[bird_soccer_player_name] FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_country] AS [T2] ON [T1].[bird_soccer_country_name] = [T2].[bird_soccer_country_id] WHERE [T2].[bird_soccer_country_name] = 'Zimbabwea';

-- question_id=133 source_index=1920
SELECT SUM(CASE WHEN [T2].[bird_soccer_batting_hand] = 'Left-hand bat' THEN 1 ELSE 0 END) FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_batting_style] AS [T2] ON [T1].[bird_soccer_batting_hand] = [T2].[bird_soccer_batting_id];

-- question_id=134 source_index=1921
SELECT SUM(CASE WHEN [T2].[bird_soccer_win_type] <> 'runs' THEN 1 ELSE 0 END) FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_win_by] AS [T2] ON [T1].[bird_soccer_win_type] = [T2].[bird_soccer_win_id];

-- question_id=135 source_index=1922
SELECT [T1].[bird_soccer_umpire_name] FROM [bird_soccer_umpire] AS [T1] INNER JOIN [bird_soccer_country] AS [T2] ON [T1].[bird_soccer_umpire_country] = [T2].[bird_soccer_country_id] WHERE [T2].[bird_soccer_country_name] = 'New Zealand';

-- question_id=136 source_index=1923
SELECT [T3].[bird_soccer_country_name] FROM [bird_soccer_bowling_style] AS [T1] INNER JOIN [bird_soccer_player] AS [T2] ON [T1].[bird_soccer_bowling_id] = [T2].[bird_soccer_bowling_skill] INNER JOIN [bird_soccer_country] AS [T3] ON [T2].[bird_soccer_country_name] = [T3].[bird_soccer_country_id] WHERE [T1].[bird_soccer_bowling_skill] = 'Slow left-arm chinaman';

-- question_id=137 source_index=1924
SELECT [T1].[bird_soccer_venue_name] FROM [bird_soccer_venue] AS [T1] INNER JOIN [bird_soccer_match] AS [T2] ON [T1].[bird_soccer_venue_id] = [T2].[bird_soccer_venue_id] INNER JOIN [bird_soccer_team] AS [T3] ON [T2].[bird_soccer_team_1] = [T3].[bird_soccer_team_id] WHERE [T3].[bird_soccer_team_name] = 'Kochi Tuskers Kerala' GROUP BY [T1].[bird_soccer_venue_name];

-- question_id=138 source_index=1925
SELECT COUNT([T1].[bird_soccer_runs_scored]) FROM [bird_soccer_batsman_scored] AS [T1] INNER JOIN [bird_soccer_ball_by_ball] AS [T2] ON [T1].[bird_soccer_match_id] = [T2].[bird_soccer_match_id] INNER JOIN [bird_soccer_match] AS [T3] ON [T2].[bird_soccer_match_id] = [T3].[bird_soccer_match_id] INNER JOIN [bird_soccer_team] AS [T4] ON [T3].[bird_soccer_team_1] = [T4].[bird_soccer_team_id] WHERE [T2].[bird_soccer_team_batting] = 1 OR [T2].[bird_soccer_team_batting] = 2 AND [T4].[bird_soccer_team_name] = 'Delhi Daredevils';

-- question_id=139 source_index=1926
SELECT CAST(COUNT(CASE WHEN [T2].[bird_soccer_win_margin] < 10 THEN 1 ELSE 0 END) AS FLOAT) * 100 / NULLIF(SUM([T1].[bird_soccer_venue_id]), 0) FROM [bird_soccer_venue] AS [T1] INNER JOIN [bird_soccer_match] AS [T2] ON [T1].[bird_soccer_venue_id] = [T2].[bird_soccer_venue_id] WHERE [T1].[bird_soccer_venue_name] = 'Dr DY Patil Sports Academy';

-- question_id=140 source_index=1927
SELECT AVG([T1].[bird_soccer_extra_runs]) FROM [bird_soccer_extra_runs] AS [T1] INNER JOIN [bird_soccer_extra_type] AS [T2] ON [T1].[bird_soccer_extra_type_id] = [T2].[bird_soccer_extra_id] WHERE [T2].[bird_soccer_extra_name] = 'noballs';

-- question_id=141 source_index=1928
SELECT TOP 5 [bird_soccer_player_id] FROM [bird_soccer_player] ORDER BY [bird_soccer_bowling_skill] DESC;

-- question_id=142 source_index=1929
SELECT COUNT(*) FROM [bird_soccer_player] WHERE [bird_soccer_dob] < '1975-10-16' AND [bird_soccer_bowling_skill] < 3;

-- question_id=143 source_index=1930
SELECT TOP 1 [bird_soccer_player_name] FROM [bird_soccer_player] ORDER BY [bird_soccer_dob] DESC;

-- question_id=144 source_index=1931
SELECT [bird_soccer_man_of_the_series] FROM [bird_soccer_season] WHERE [bird_soccer_season_year] > 2011 AND [bird_soccer_season_year] < 2015;

-- question_id=145 source_index=1932
SELECT SUM([bird_soccer_runs_scored]) FROM [bird_soccer_batsman_scored] WHERE [bird_soccer_match_id] = 335988 AND [bird_soccer_innings_no] = 2;

-- question_id=146 source_index=1933
SELECT SUM(CASE WHEN [bird_soccer_runs_scored] > 3 THEN 1 ELSE 0 END) FROM [bird_soccer_batsman_scored] WHERE [bird_soccer_match_id] > 335989 AND [bird_soccer_match_id] < 337000 AND [bird_soccer_innings_no] = 1 AND [bird_soccer_over_id] = 1 AND [bird_soccer_ball_id] = 1;

-- question_id=147 source_index=1934
SELECT [T1].[bird_soccer_match_id], [T1].[bird_soccer_match_date] FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_venue] AS [T2] ON [T1].[bird_soccer_venue_id] = [T2].[bird_soccer_venue_id] WHERE [T2].[bird_soccer_venue_name] = 'Kingsmead';

-- question_id=148 source_index=1935
SELECT SUM(CASE WHEN [bird_soccer_venue_name] = 'MA Chidambaram Stadium' THEN 1 ELSE 0 END) FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_venue] AS [T2] ON [T1].[bird_soccer_venue_id] = [T2].[bird_soccer_venue_id] WHERE [bird_soccer_match_date] BETWEEN '2009-05-09' AND '2011-08-08';

-- question_id=149 source_index=1936
SELECT [T2].[bird_soccer_venue_name], [T3].[bird_soccer_city_name] FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_venue] AS [T2] ON [T1].[bird_soccer_venue_id] = [T2].[bird_soccer_venue_id] INNER JOIN [bird_soccer_city] AS [T3] ON [T2].[bird_soccer_city_id] = [T3].[bird_soccer_city_id] WHERE [T1].[bird_soccer_match_id] = '336005';

-- question_id=150 source_index=1937
SELECT [T2].[bird_soccer_toss_name], [T1].[bird_soccer_toss_decide], [T1].[bird_soccer_toss_winner] FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_toss_decision] AS [T2] ON [T1].[bird_soccer_toss_decide] = [T2].[bird_soccer_toss_id] WHERE [T1].[bird_soccer_match_id] = '336011';

-- question_id=151 source_index=1938
SELECT SUM(CASE WHEN [T1].[bird_soccer_dob] < '1980-4-11' THEN 1 ELSE 0 END) FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_country] AS [T2] ON [T1].[bird_soccer_country_name] = [T2].[bird_soccer_country_id] WHERE [T2].[bird_soccer_country_name] = 'South Africa';

-- question_id=152 source_index=1939
SELECT [T2].[bird_soccer_player_name] FROM [bird_soccer_bowling_style] AS [T1] INNER JOIN [bird_soccer_player] AS [T2] ON [T1].[bird_soccer_bowling_id] = [T2].[bird_soccer_bowling_skill] WHERE [T1].[bird_soccer_bowling_skill] = 'Legbreak';

-- question_id=153 source_index=1940
SELECT TOP 1 [T1].[bird_soccer_match_date], [T4].[bird_soccer_role_desc] FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_player_match] AS [T2] ON [T1].[bird_soccer_match_id] = [T2].[bird_soccer_match_id] INNER JOIN [bird_soccer_player] AS [T3] ON [T2].[bird_soccer_player_id] = [T3].[bird_soccer_player_id] INNER JOIN [bird_soccer_rolee] AS [T4] ON [T2].[bird_soccer_role_id] = [T4].[bird_soccer_role_id] ORDER BY [T3].[bird_soccer_dob] DESC;

-- question_id=154 source_index=1941
SELECT [T1].[bird_soccer_match_id] FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_player] AS [T2] ON [T1].[bird_soccer_man_of_the_match] = [T2].[bird_soccer_player_id] WHERE [T2].[bird_soccer_player_name] = 'V Kohli';

-- question_id=155 source_index=1942
SELECT SUM(CASE WHEN DATEPART(year, [T1].[bird_soccer_match_date]) BETWEEN 2011 AND 2012 THEN 1 ELSE 0 END) FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_player] AS [T2] ON [T2].[bird_soccer_player_id] = [T1].[bird_soccer_man_of_the_match] INNER JOIN [bird_soccer_country] AS [T3] ON [T3].[bird_soccer_country_id] = [T2].[bird_soccer_country_name] WHERE [T3].[bird_soccer_country_name] = 'Australia';

-- question_id=156 source_index=1943
SELECT [T1].[bird_soccer_player_name] FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_season] AS [T2] ON [T1].[bird_soccer_player_id] = [T2].[bird_soccer_man_of_the_series] AND [T2].[bird_soccer_man_of_the_series] = [T2].[bird_soccer_orange_cap];

-- question_id=157 source_index=1944
SELECT [T1].[bird_soccer_match_date] FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_team] AS [T2] ON [T1].[bird_soccer_match_winner] = [T2].[bird_soccer_team_id] WHERE [T2].[bird_soccer_team_name] = 'Sunrisers Hyderabad';

-- question_id=158 source_index=1945
SELECT [T1].[bird_soccer_umpire_name], [T1].[bird_soccer_umpire_id] FROM [bird_soccer_umpire] AS [T1] INNER JOIN [bird_soccer_country] AS [T2] ON [T1].[bird_soccer_umpire_country] = [T2].[bird_soccer_country_id] WHERE [T2].[bird_soccer_country_name] = 'England';

-- question_id=159 source_index=1946
SELECT CAST(COUNT(CASE WHEN [T1].[bird_soccer_toss_name] = 'bat' THEN [T3].[bird_soccer_runs_scored] ELSE NULL END) AS FLOAT) / NULLIF(SUM(CASE WHEN [T1].[bird_soccer_toss_name] = 'field' THEN 1 ELSE 0 END), 0) FROM [bird_soccer_toss_decision] AS [T1] INNER JOIN [bird_soccer_match] AS [T2] ON [T1].[bird_soccer_toss_id] = [T2].[bird_soccer_toss_decide] INNER JOIN [bird_soccer_batsman_scored] AS [T3] ON [T2].[bird_soccer_match_id] = [T3].[bird_soccer_match_id] WHERE [T2].[bird_soccer_match_id] = 335987 AND [T2].[bird_soccer_match_date] = '2008-04-18' GROUP BY [T3].[bird_soccer_over_id] HAVING SUM(CASE WHEN [T1].[bird_soccer_toss_name] = 'field' THEN 1 ELSE 0 END) = 17;

-- question_id=160 source_index=1947
SELECT CAST(COUNT(CASE WHEN [T1].[bird_soccer_toss_name] = 'bat' THEN [T3].[bird_soccer_runs_scored] ELSE NULL END) AS FLOAT) / NULLIF(SUM(CASE WHEN [T1].[bird_soccer_toss_name] = 'field' THEN 1 ELSE 0 END), 0) FROM [bird_soccer_toss_decision] AS [T1] INNER JOIN [bird_soccer_match] AS [T2] ON [T1].[bird_soccer_toss_id] = [T2].[bird_soccer_toss_decide] INNER JOIN [bird_soccer_batsman_scored] AS [T3] ON [T2].[bird_soccer_match_id] = [T3].[bird_soccer_match_id] WHERE [T2].[bird_soccer_match_id] = 335987 AND [T2].[bird_soccer_match_date] = '2008-04-18' GROUP BY [T3].[bird_soccer_over_id] HAVING SUM(CASE WHEN [T1].[bird_soccer_toss_name] = 'field' THEN 1 ELSE 0 END) = 16;

-- question_id=161 source_index=1948
SELECT TOP 1 [bird_soccer_match_id] FROM [bird_soccer_match] ORDER BY [bird_soccer_match_winner] DESC;

-- question_id=162 source_index=1949
SELECT TOP 1 [bird_soccer_dob] FROM [bird_soccer_player] GROUP BY [bird_soccer_dob] ORDER BY COUNT([bird_soccer_dob]) DESC;

-- question_id=163 source_index=1950
SELECT TOP 1 [bird_soccer_match_date] FROM [bird_soccer_match] ORDER BY [bird_soccer_win_margin] DESC;

-- question_id=164 source_index=1951
SELECT TOP 1 [bird_soccer_season_id] FROM [bird_soccer_match] GROUP BY [bird_soccer_season_id] ORDER BY COUNT([bird_soccer_match_id]);

-- question_id=165 source_index=1952
SELECT COUNT([bird_soccer_match_id]) FROM [bird_soccer_match] GROUP BY [bird_soccer_man_of_the_match] HAVING COUNT([bird_soccer_match_id]) >= 5;

-- question_id=166 source_index=1953
SELECT TOP 1 [T1].[bird_soccer_player_name] FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_match] AS [T2] ON [T1].[bird_soccer_player_id] = [T2].[bird_soccer_man_of_the_match] WHERE [T2].[bird_soccer_season_id] = 9 ORDER BY [T2].[bird_soccer_match_date] DESC;

-- question_id=167 source_index=1954
SELECT TOP 1 [T1].[bird_soccer_team_name] FROM [bird_soccer_team] AS [T1] INNER JOIN [bird_soccer_match] AS [T2] ON [T1].[bird_soccer_team_id] = [T2].[bird_soccer_match_winner] WHERE [T2].[bird_soccer_season_id] = 1 ORDER BY [T2].[bird_soccer_match_date];

-- question_id=168 source_index=1955
SELECT SUM(CASE WHEN [T2].[bird_soccer_country_name] = 'U.A.E' THEN 1 ELSE 0 END) FROM [bird_soccer_city] AS [T1] INNER JOIN [bird_soccer_country] AS [T2] ON [T1].[bird_soccer_country_id] = [T2].[bird_soccer_country_id];

-- question_id=169 source_index=1956
SELECT [T1].[bird_soccer_umpire_name] FROM [bird_soccer_umpire] AS [T1] INNER JOIN [bird_soccer_country] AS [T2] ON [T2].[bird_soccer_country_id] = [T1].[bird_soccer_umpire_country] WHERE [T2].[bird_soccer_country_name] = 'England';

-- question_id=170 source_index=1957
SELECT [T1].[bird_soccer_player_name] FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_bowling_style] AS [T2] ON [T1].[bird_soccer_bowling_skill] = [T2].[bird_soccer_bowling_id] WHERE [T2].[bird_soccer_bowling_skill] = 'Legbreak';

-- question_id=171 source_index=1958
SELECT SUM(CASE WHEN [T1].[bird_soccer_season_id] = 8 THEN 1 ELSE 0 END) FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_team] AS [T2] ON [T1].[bird_soccer_team_1] = [T2].[bird_soccer_team_id] OR [T1].[bird_soccer_team_2] = [T2].[bird_soccer_team_id] WHERE [T2].[bird_soccer_team_name] = 'Rajasthan Royals';

-- question_id=172 source_index=1959
SELECT [T2].[bird_soccer_country_name] FROM [bird_soccer_umpire] AS [T1] INNER JOIN [bird_soccer_country] AS [T2] ON [T2].[bird_soccer_country_id] = [T1].[bird_soccer_umpire_country] WHERE [T1].[bird_soccer_umpire_name] = 'TH Wijewardene';

-- question_id=173 source_index=1960
SELECT [T1].[bird_soccer_venue_name] FROM [bird_soccer_venue] AS [T1] INNER JOIN [bird_soccer_city] AS [T2] ON [T1].[bird_soccer_city_id] = [T2].[bird_soccer_city_id] WHERE [T2].[bird_soccer_city_name] = 'Abu Dhabi';

-- question_id=174 source_index=1961
SELECT TOP 1 [T1].[bird_soccer_country_name] FROM [bird_soccer_country] AS [T1] INNER JOIN [bird_soccer_player] AS [T2] ON [T1].[bird_soccer_country_id] = [T2].[bird_soccer_country_name] ORDER BY [T2].[bird_soccer_dob] DESC;

-- question_id=175 source_index=1962
SELECT TOP 1 [T3].[bird_soccer_player_name] FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_player_match] AS [T2] ON [T1].[bird_soccer_match_winner] = [T2].[bird_soccer_team_id] INNER JOIN [bird_soccer_player] AS [T3] ON [T2].[bird_soccer_player_id] = [T3].[bird_soccer_player_id] WHERE [T1].[bird_soccer_season_id] = 1 ORDER BY [T1].[bird_soccer_match_date];

-- question_id=176 source_index=1963
SELECT TOP 1 [T1].[bird_soccer_player_name] FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_season] AS [T2] ON [T1].[bird_soccer_player_id] = [T2].[bird_soccer_purple_cap] ORDER BY [T2].[bird_soccer_season_year] - DATEPART(year, [T1].[bird_soccer_dob]);

-- question_id=177 source_index=1964
SELECT TOP 1 [T1].[bird_soccer_venue_name], [T2].[bird_soccer_city_name], [T3].[bird_soccer_country_name] FROM [bird_soccer_venue] AS [T1] INNER JOIN [bird_soccer_city] AS [T2] ON [T1].[bird_soccer_city_id] = [T2].[bird_soccer_city_id] INNER JOIN [bird_soccer_country] AS [T3] ON [T2].[bird_soccer_country_id] = [T3].[bird_soccer_country_id] INNER JOIN [bird_soccer_match] AS [T4] ON [T1].[bird_soccer_venue_id] = [T4].[bird_soccer_venue_id] ORDER BY [T4].[bird_soccer_match_date] DESC;

-- question_id=178 source_index=1965
SELECT SUM(CASE WHEN [bird_soccer_innings_no] = 1 THEN 1 ELSE 0 END) AS [IN1], SUM(CASE WHEN [bird_soccer_innings_no] = 2 THEN 1 ELSE 0 END) AS [IN2] FROM [bird_soccer_ball_by_ball] WHERE [bird_soccer_match_id] = 336011;

-- question_id=179 source_index=1966
SELECT [bird_soccer_ball_id], [bird_soccer_runs_scored], [bird_soccer_innings_no] FROM [bird_soccer_batsman_scored] WHERE [bird_soccer_match_id] = 335988 AND [bird_soccer_over_id] = 20;

-- question_id=180 source_index=1967
SELECT COUNT([bird_soccer_match_id]) FROM [bird_soccer_match] WHERE [bird_soccer_match_date] LIKE '2011%';

-- question_id=181 source_index=1968
SELECT 2022 - DATEPART(year, [bird_soccer_dob]) FROM [bird_soccer_player] WHERE [bird_soccer_player_name] = 'Ishan Kishan';

-- question_id=182 source_index=1969
SELECT CAST(SUM(CASE WHEN [bird_soccer_toss_winner] = [bird_soccer_match_winner] THEN 1 ELSE 0 END) AS FLOAT) / NULLIF(SUM(CASE WHEN [bird_soccer_match_date] LIKE '2012%' THEN 1 ELSE 0 END), 0) FROM [bird_soccer_match];

-- question_id=183 source_index=1970
SELECT COUNT([bird_soccer_match_id]) FROM [bird_soccer_match] WHERE [bird_soccer_match_date] LIKE '2009%' AND [bird_soccer_win_margin] < 10;

-- question_id=184 source_index=1971
SELECT TOP 2 [T1].[bird_soccer_player_name] FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_player_match] AS [T2] ON [T1].[bird_soccer_player_id] = [T2].[bird_soccer_player_id] INNER JOIN [bird_soccer_match] AS [T3] ON [T2].[bird_soccer_match_id] = [T3].[bird_soccer_match_id] WHERE DATEPART(year, [T3].[bird_soccer_match_date]) = '2014' AND DATEPART(month, [T3].[bird_soccer_match_date]) = '6';

-- question_id=185 source_index=1972
SELECT SUM(CASE WHEN [T2].[bird_soccer_player_name] = 'Mohammad Hafeez' THEN 1 ELSE 0 END) FROM [bird_soccer_player_match] AS [T1] INNER JOIN [bird_soccer_player] AS [T2] ON [T1].[bird_soccer_player_id] = [T2].[bird_soccer_player_id];

-- question_id=186 source_index=1973
SELECT [T1].[bird_soccer_player_name] FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_country] AS [T2] ON [T1].[bird_soccer_country_name] = [T2].[bird_soccer_country_id] WHERE [T2].[bird_soccer_country_name] = 'South Africa' AND [T1].[bird_soccer_dob] LIKE '1984%';

-- question_id=187 source_index=1974
SELECT CAST(SUM(CASE WHEN [T1].[bird_soccer_match_winner] = [T2].[bird_soccer_team_id] THEN 1 ELSE 0 END) AS FLOAT) * 100 / NULLIF(COUNT([T1].[bird_soccer_match_id]), 0) FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_team] AS [T2] ON [T1].[bird_soccer_team_1] = [T2].[bird_soccer_team_id] OR [T1].[bird_soccer_team_2] = [T2].[bird_soccer_team_id] WHERE [T2].[bird_soccer_team_name] = 'Mumbai Indians' AND [T1].[bird_soccer_match_date] LIKE '2009%';

-- question_id=188 source_index=1975
SELECT CAST(SUM(CASE WHEN [T2].[bird_soccer_batting_hand] = 'Left-hand bat' THEN 1 ELSE 0 END) AS FLOAT) / NULLIF(SUM(CASE WHEN [T2].[bird_soccer_batting_hand] = 'Right-hand bat' THEN 1 ELSE 0 END), 0) FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_batting_style] AS [T2] ON [T1].[bird_soccer_batting_hand] = [T2].[bird_soccer_batting_id];

-- question_id=189 source_index=1976
SELECT TOP 1 [T1].[bird_soccer_player_name], [T2].[bird_soccer_country_name] FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_country] AS [T2] ON [T1].[bird_soccer_country_name] = [T2].[bird_soccer_country_id] ORDER BY [T1].[bird_soccer_dob];

-- question_id=190 source_index=1977
SELECT [T1].[bird_soccer_bowling_skill] FROM [bird_soccer_bowling_style] AS [T1] INNER JOIN [bird_soccer_player] AS [T2] ON [T1].[bird_soccer_bowling_id] = [T2].[bird_soccer_bowling_skill] INNER JOIN [bird_soccer_country] AS [T3] ON [T2].[bird_soccer_country_name] = [T3].[bird_soccer_country_id] WHERE [T3].[bird_soccer_country_name] = 'Zimbabwea';

-- question_id=191 source_index=1978
SELECT [T1].[bird_soccer_umpire_id], [T1].[bird_soccer_umpire_name] FROM [bird_soccer_umpire] AS [T1] INNER JOIN [bird_soccer_country] AS [T2] ON [T1].[bird_soccer_umpire_country] = [T2].[bird_soccer_country_id] WHERE [T2].[bird_soccer_country_name] = 'New Zealand';

-- question_id=192 source_index=1979
SELECT [T1].[bird_soccer_player_name] FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_player_match] AS [T2] ON [T1].[bird_soccer_player_id] = [T2].[bird_soccer_player_id] INNER JOIN [bird_soccer_team] AS [T3] ON [T2].[bird_soccer_team_id] = [T3].[bird_soccer_team_id] INNER JOIN [bird_soccer_rolee] AS [T4] ON [T2].[bird_soccer_role_id] = [T4].[bird_soccer_role_id] WHERE [T3].[bird_soccer_team_name] = 'Rising Pune Supergiants' AND [T4].[bird_soccer_role_desc] = 'CaptainKeeper' GROUP BY [T1].[bird_soccer_player_name];

-- question_id=193 source_index=1980
SELECT SUM(CASE WHEN [bird_soccer_match_date] LIKE '2013%' THEN 1 ELSE 0 END) FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_team] AS [T2] ON [T1].[bird_soccer_match_winner] = [T2].[bird_soccer_team_id] WHERE [T2].[bird_soccer_team_name] = 'Sunrisers Hyderabad';

-- question_id=194 source_index=1981
SELECT [T1].[bird_soccer_match_id] FROM [bird_soccer_extra_runs] AS [T1] INNER JOIN [bird_soccer_extra_type] AS [T2] ON [T1].[bird_soccer_extra_type_id] = [T2].[bird_soccer_extra_id] WHERE [T2].[bird_soccer_extra_name] = 'penalty';

-- question_id=195 source_index=1982
SELECT TOP 1 [T1].[bird_soccer_team_name] FROM [bird_soccer_team] AS [T1] INNER JOIN [bird_soccer_match] AS [T2] ON [T1].[bird_soccer_team_id] = [T2].[bird_soccer_team_1] OR [T1].[bird_soccer_team_id] = [T2].[bird_soccer_team_2] INNER JOIN [bird_soccer_win_by] AS [T3] ON [T2].[bird_soccer_win_type] = [T3].[bird_soccer_win_id] WHERE DATEPART(year, [T2].[bird_soccer_match_date]) = '2015' AND [T3].[bird_soccer_win_type] = 'Tie';

-- question_id=196 source_index=1983
SELECT CAST(COUNT([T1].[bird_soccer_player_out]) AS FLOAT) / NULLIF(COUNT([T1].[bird_soccer_match_id]), 0), SUM(CASE WHEN [T2].[bird_soccer_out_name] = 'lbw' THEN 1 ELSE 0 END) FROM [bird_soccer_wicket_taken] AS [T1] INNER JOIN [bird_soccer_out_type] AS [T2] ON [T1].[bird_soccer_kind_out] = [T2].[bird_soccer_out_id] WHERE [T1].[bird_soccer_innings_no] = 2;

-- question_id=197 source_index=1984
SELECT COUNT([bird_soccer_match_id]) FROM [bird_soccer_match] WHERE [bird_soccer_match_date] LIKE '2008%';

-- question_id=198 source_index=1985
SELECT COUNT([bird_soccer_match_id]) FROM [bird_soccer_wicket_taken] WHERE [bird_soccer_innings_no] = 2;

-- question_id=199 source_index=1986
SELECT [T1].[bird_soccer_country_name] FROM [bird_soccer_country] AS [T1] INNER JOIN [bird_soccer_city] AS [T2] ON [T1].[bird_soccer_country_id] = [T2].[bird_soccer_country_id] WHERE [bird_soccer_city_name] = 'Rajkot';

-- question_id=200 source_index=1987
SELECT SUM(CASE WHEN [T2].[bird_soccer_win_type] = 'wickets' THEN 1 ELSE 0 END) FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_win_by] AS [T2] ON [T1].[bird_soccer_win_type] = [T2].[bird_soccer_win_id];

-- question_id=201 source_index=1988
SELECT [T1].[bird_soccer_team_name] FROM [bird_soccer_team] AS [T1] INNER JOIN [bird_soccer_match] AS [T2] ON [T1].[bird_soccer_team_id] = [T2].[bird_soccer_team_1] WHERE [T2].[bird_soccer_win_margin] = 38 AND [bird_soccer_match_date] = '2009-04-30';

-- question_id=202 source_index=1989
SELECT [T1].[bird_soccer_team_name] FROM [bird_soccer_team] AS [T1] INNER JOIN [bird_soccer_player_match] AS [T2] ON [T1].[bird_soccer_team_id] = [T2].[bird_soccer_team_id] INNER JOIN [bird_soccer_player] AS [T3] ON [T2].[bird_soccer_player_id] = [T3].[bird_soccer_player_id] WHERE [T2].[bird_soccer_match_id] = 335989 AND [T3].[bird_soccer_player_name] = 'T Kohli';

-- question_id=203 source_index=1990
SELECT COUNT([T1].[bird_soccer_venue_name]) FROM [bird_soccer_venue] AS [T1] INNER JOIN [bird_soccer_city] AS [T2] ON [T1].[bird_soccer_city_id] = [T2].[bird_soccer_city_id] INNER JOIN [bird_soccer_country] AS [T3] ON [T2].[bird_soccer_country_id] = [T3].[bird_soccer_country_id] WHERE [T3].[bird_soccer_country_name] = 'South Africa' AND [T2].[bird_soccer_city_name] = 'Centurion';

-- question_id=204 source_index=1991
SELECT COUNT([T1].[bird_soccer_match_winner]) FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_team] AS [T2] ON [T2].[bird_soccer_team_id] = [T1].[bird_soccer_team_1] OR [T2].[bird_soccer_team_id] = [T1].[bird_soccer_team_2] WHERE [T2].[bird_soccer_team_name] = 'Delhi Daredevils' AND [T1].[bird_soccer_match_date] LIKE '2014%';

-- question_id=205 source_index=1992
SELECT TOP 1 [T2].[bird_soccer_match_id] FROM [bird_soccer_team] AS [T1] INNER JOIN [bird_soccer_match] AS [T2] ON [T1].[bird_soccer_team_id] = [T2].[bird_soccer_match_winner] WHERE [T1].[bird_soccer_team_name] = 'Royal Challengers Bangalore' AND [T2].[bird_soccer_match_date] LIKE '2012%' ORDER BY [T2].[bird_soccer_win_margin] DESC;

-- question_id=206 source_index=1993
SELECT COUNT([T1].[bird_soccer_match_id]) FROM [bird_soccer_player_match] AS [T1] INNER JOIN [bird_soccer_player] AS [T2] ON [T1].[bird_soccer_player_id] = [T2].[bird_soccer_player_id] INNER JOIN [bird_soccer_rolee] AS [T3] ON [T1].[bird_soccer_role_id] = [T3].[bird_soccer_role_id] WHERE [T2].[bird_soccer_player_name] = 'K Goel' AND [T3].[bird_soccer_role_id] = 3;

-- question_id=207 source_index=1994
SELECT AVG([T1].[bird_soccer_win_margin]) FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_venue] AS [T2] ON [T1].[bird_soccer_venue_id] = [T2].[bird_soccer_venue_id] WHERE [T2].[bird_soccer_venue_name] = 'Newlands';

-- question_id=208 source_index=1995
SELECT [bird_soccer_team_name] FROM [bird_soccer_team] WHERE [bird_soccer_team_id] = (SELECT CASE WHEN [bird_soccer_team_1] = [bird_soccer_match_winner] THEN [bird_soccer_team_2] ELSE [bird_soccer_team_1] END FROM [bird_soccer_match] WHERE [bird_soccer_match_id] = 336039);

-- question_id=209 source_index=1996
SELECT [T1].[bird_soccer_venue_name] FROM [bird_soccer_venue] AS [T1] INNER JOIN [bird_soccer_match] AS [T2] ON [T1].[bird_soccer_venue_id] = [T2].[bird_soccer_venue_id] WHERE [T2].[bird_soccer_match_id] = 829768;

-- question_id=210 source_index=1997
SELECT TOP 1 [T1].[bird_soccer_team_name] FROM [bird_soccer_team] AS [T1] INNER JOIN [bird_soccer_match] AS [T2] ON [T1].[bird_soccer_team_id] = [T2].[bird_soccer_team_2] ORDER BY [T2].[bird_soccer_win_margin];

-- question_id=211 source_index=1998
SELECT CAST(SUM(CASE WHEN [T2].[bird_soccer_match_winner] = 7 THEN 1 ELSE 0 END) AS FLOAT) * 100 / NULLIF(COUNT([T2].[bird_soccer_match_winner]), 0) FROM [bird_soccer_team] AS [T1] INNER JOIN [bird_soccer_match] AS [T2] ON [T1].[bird_soccer_team_id] = [T2].[bird_soccer_match_winner] WHERE [T2].[bird_soccer_match_date] LIKE '2013%';

-- question_id=212 source_index=1999
SELECT SUM(CASE WHEN [T3].[bird_soccer_role_id] = 1 THEN 1 ELSE 0 END) - SUM(CASE WHEN [T3].[bird_soccer_role_id] > 1 THEN 1 ELSE 0 END) FROM [bird_soccer_player_match] AS [T1] INNER JOIN [bird_soccer_player] AS [T2] ON [T1].[bird_soccer_player_id] = [T2].[bird_soccer_player_id] INNER JOIN [bird_soccer_rolee] AS [T3] ON [T1].[bird_soccer_role_id] = [T3].[bird_soccer_role_id] WHERE [T2].[bird_soccer_player_name] = 'SC Ganguly';

-- question_id=213 source_index=2000
SELECT COUNT([bird_soccer_player_name]) FROM [bird_soccer_player] WHERE [bird_soccer_bowling_skill] > 2;

-- question_id=214 source_index=2001
SELECT COUNT([bird_soccer_player_name]) FROM [bird_soccer_player] WHERE [bird_soccer_dob] LIKE '1970%';

-- question_id=215 source_index=2002
SELECT COUNT([bird_soccer_player_name]) FROM [bird_soccer_player] WHERE [bird_soccer_dob] LIKE '198%' AND [bird_soccer_bowling_skill] = 2;

-- question_id=216 source_index=2003
SELECT COUNT([bird_soccer_match_id]) FROM [bird_soccer_match] WHERE [bird_soccer_match_date] LIKE '2008-04%';

-- question_id=217 source_index=2004
SELECT [bird_soccer_city_name] FROM [bird_soccer_city] WHERE [bird_soccer_country_id] = 3;

-- question_id=218 source_index=2005
SELECT COUNT([bird_soccer_match_id]) FROM [bird_soccer_match] WHERE [bird_soccer_match_date] LIKE '2008%' AND NOT [bird_soccer_match_winner] IS NULL;

-- question_id=219 source_index=2006
SELECT [bird_soccer_country_id] FROM [bird_soccer_city] WHERE [bird_soccer_city_name] = 'East London';

-- question_id=220 source_index=2007
SELECT 2008 - DATEPART(year, [bird_soccer_dob]) FROM [bird_soccer_player] WHERE [bird_soccer_player_name] = 'SC Ganguly';

-- question_id=221 source_index=2008
SELECT [T1].[bird_soccer_player_name] FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_batting_style] AS [T2] ON [T1].[bird_soccer_batting_hand] = [T2].[bird_soccer_batting_id] WHERE [T2].[bird_soccer_batting_hand] = 'Left-hand bat';

-- question_id=222 source_index=2009
SELECT COUNT([T1].[bird_soccer_player_id]) FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_country] AS [T2] ON [T1].[bird_soccer_country_name] = [T2].[bird_soccer_country_id] WHERE [T2].[bird_soccer_country_name] = 'India';

-- question_id=223 source_index=2010
SELECT [T1].[bird_soccer_player_name] FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_country] AS [T2] ON [T1].[bird_soccer_country_name] = [T2].[bird_soccer_country_id] WHERE [T2].[bird_soccer_country_name] = 'England';

-- question_id=224 source_index=2011
SELECT [T1].[bird_soccer_venue_name] FROM [bird_soccer_venue] AS [T1] INNER JOIN [bird_soccer_city] AS [T2] ON [T1].[bird_soccer_city_id] = [T2].[bird_soccer_city_id] WHERE [T2].[bird_soccer_city_name] = 'Bangalore';

-- question_id=225 source_index=2012
SELECT [T1].[bird_soccer_player_name] FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_match] AS [T2] ON [T1].[bird_soccer_player_id] = [T2].[bird_soccer_man_of_the_match] INNER JOIN [bird_soccer_player_match] AS [T3] ON [T3].[bird_soccer_player_id] = [T1].[bird_soccer_player_id] INNER JOIN [bird_soccer_season] AS [T4] ON [T2].[bird_soccer_season_id] = [T4].[bird_soccer_season_id] WHERE [T4].[bird_soccer_season_year] = 2008 GROUP BY [T1].[bird_soccer_player_name];

-- question_id=226 source_index=2013
SELECT [T1].[bird_soccer_player_name] FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_player_match] AS [T2] ON [T1].[bird_soccer_player_id] = [T2].[bird_soccer_player_id] INNER JOIN [bird_soccer_batsman_scored] AS [T3] ON [T2].[bird_soccer_match_id] = [T3].[bird_soccer_match_id] WHERE [T3].[bird_soccer_runs_scored] < 3 GROUP BY [T1].[bird_soccer_player_name];

-- question_id=227 source_index=2014
SELECT [T3].[bird_soccer_role_desc] FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_player_match] AS [T2] ON [T1].[bird_soccer_player_id] = [T2].[bird_soccer_player_id] INNER JOIN [bird_soccer_rolee] AS [T3] ON [T2].[bird_soccer_role_id] = [T3].[bird_soccer_role_id] WHERE [T1].[bird_soccer_player_name] = 'SC Ganguly' GROUP BY [T3].[bird_soccer_role_desc];

-- question_id=228 source_index=2015
SELECT [T1].[bird_soccer_player_name] FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_player_match] AS [T2] ON [T1].[bird_soccer_player_id] = [T2].[bird_soccer_player_id] INNER JOIN [bird_soccer_rolee] AS [T3] ON [T2].[bird_soccer_role_id] = [T3].[bird_soccer_role_id] WHERE [T3].[bird_soccer_role_desc] = 'Keeper' GROUP BY [T1].[bird_soccer_player_name];

-- question_id=229 source_index=2016
SELECT [T1].[bird_soccer_player_name] FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_player_match] AS [T2] ON [T1].[bird_soccer_player_id] = [T2].[bird_soccer_player_id] INNER JOIN [bird_soccer_team] AS [T3] ON [T2].[bird_soccer_team_id] = [T3].[bird_soccer_team_id] WHERE [T3].[bird_soccer_team_id] = 1 GROUP BY [T1].[bird_soccer_player_name];

-- question_id=230 source_index=2017
SELECT COUNT([T1].[bird_soccer_player_id]) FROM [bird_soccer_player_match] AS [T1] INNER JOIN [bird_soccer_match] AS [T2] ON [T1].[bird_soccer_match_id] = [T2].[bird_soccer_match_id] INNER JOIN [bird_soccer_rolee] AS [T3] ON [T1].[bird_soccer_role_id] = [T3].[bird_soccer_role_id] WHERE [T3].[bird_soccer_role_desc] = 'Captain' AND [T2].[bird_soccer_match_date] LIKE '2008%';

-- question_id=231 source_index=2018
SELECT [T5].[bird_soccer_team_name] FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_match] AS [T2] ON [T1].[bird_soccer_player_id] = [T2].[bird_soccer_man_of_the_match] INNER JOIN [bird_soccer_player_match] AS [T3] ON [T3].[bird_soccer_player_id] = [T1].[bird_soccer_player_id] INNER JOIN [bird_soccer_season] AS [T4] ON [T2].[bird_soccer_season_id] = [T4].[bird_soccer_season_id] INNER JOIN [bird_soccer_team] AS [T5] ON [T3].[bird_soccer_team_id] = [T5].[bird_soccer_team_id] WHERE [T4].[bird_soccer_season_year] = 2008 AND [T1].[bird_soccer_player_name] = 'SC Ganguly' GROUP BY [T5].[bird_soccer_team_name];

-- question_id=232 source_index=2019
SELECT [T2].[bird_soccer_win_type] FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_win_by] AS [T2] ON [T1].[bird_soccer_win_type] = [T2].[bird_soccer_win_id] WHERE [T1].[bird_soccer_match_id] = 336000;

-- question_id=233 source_index=2020
SELECT [T2].[bird_soccer_country_name] FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_country] AS [T2] ON [T1].[bird_soccer_country_name] = [T2].[bird_soccer_country_id] WHERE [T1].[bird_soccer_player_name] = 'SB Joshi';

-- question_id=234 source_index=2021
SELECT COUNT([T1].[bird_soccer_player_id]) FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_bowling_style] AS [T2] ON [T1].[bird_soccer_bowling_skill] = [T2].[bird_soccer_bowling_id] WHERE [T2].[bird_soccer_bowling_skill] = 'Left-arm fast';

-- question_id=235 source_index=2022
SELECT [T2].[bird_soccer_outcome_type] FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_outcome] AS [T2] ON [T1].[bird_soccer_outcome_type] = [T2].[bird_soccer_outcome_id] WHERE [T1].[bird_soccer_match_id] = '392195';

-- question_id=236 source_index=2023
SELECT TOP 1 [T3].[bird_soccer_city_name] FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_country] AS [T2] ON [T1].[bird_soccer_country_name] = [T2].[bird_soccer_country_id] INNER JOIN [bird_soccer_city] AS [T3] ON [T2].[bird_soccer_country_id] = [T3].[bird_soccer_country_id] ORDER BY [T1].[bird_soccer_dob];

-- question_id=237 source_index=2024
SELECT COUNT(DISTINCT [T2].[bird_soccer_match_id]) FROM [bird_soccer_team] AS [T1] INNER JOIN [bird_soccer_match] AS [T2] ON [T1].[bird_soccer_team_id] = [T2].[bird_soccer_match_winner] INNER JOIN [bird_soccer_player_match] AS [T3] ON [T1].[bird_soccer_team_id] = [T3].[bird_soccer_team_id] INNER JOIN [bird_soccer_season] AS [T4] ON [T2].[bird_soccer_season_id] = [T4].[bird_soccer_season_id] WHERE [T1].[bird_soccer_team_name] = 'Kings XI Punjab' AND [T4].[bird_soccer_season_year] = 2008;

-- question_id=238 source_index=2025
SELECT COUNT([T].[bird_soccer_season_year]) FROM (SELECT [T4].[bird_soccer_season_year] AS [bird_soccer_season_year] FROM [bird_soccer_team] AS [T1] INNER JOIN [bird_soccer_match] AS [T2] ON [T1].[bird_soccer_team_id] = [T2].[bird_soccer_match_winner] INNER JOIN [bird_soccer_player_match] AS [T3] ON [T1].[bird_soccer_team_id] = [T3].[bird_soccer_team_id] INNER JOIN [bird_soccer_season] AS [T4] ON [T2].[bird_soccer_season_id] = [T4].[bird_soccer_season_id] WHERE [T1].[bird_soccer_team_name] = 'Pune Warriors' GROUP BY [T4].[bird_soccer_season_year]) AS [T];

-- question_id=239 source_index=2026
SELECT [T1].[bird_soccer_dob], [T3].[bird_soccer_role_desc] FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_player_match] AS [T2] ON [T1].[bird_soccer_player_id] = [T2].[bird_soccer_player_id] INNER JOIN [bird_soccer_rolee] AS [T3] ON [T2].[bird_soccer_role_id] = [T3].[bird_soccer_role_id] WHERE [T1].[bird_soccer_player_name] = 'R Dravid' GROUP BY [T1].[bird_soccer_dob], [T3].[bird_soccer_role_desc];

-- question_id=240 source_index=2027
SELECT COUNT([T2].[bird_soccer_man_of_the_match]) FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_match] AS [T2] ON [T1].[bird_soccer_player_id] = [T2].[bird_soccer_man_of_the_match] INNER JOIN [bird_soccer_player_match] AS [T3] ON [T3].[bird_soccer_player_id] = [T1].[bird_soccer_player_id] WHERE [T1].[bird_soccer_player_name] = 'SC Ganguly';

-- question_id=241 source_index=2028
SELECT COUNT([T].[bird_soccer_match_id]) FROM (SELECT [T2].[bird_soccer_match_id] AS [bird_soccer_match_id] FROM [bird_soccer_team] AS [T1] INNER JOIN [bird_soccer_match] AS [T2] ON [T1].[bird_soccer_team_id] = [T2].[bird_soccer_match_winner] INNER JOIN [bird_soccer_player_match] AS [T3] ON [T1].[bird_soccer_team_id] = [T3].[bird_soccer_team_id] WHERE [T1].[bird_soccer_team_name] = 'Mumbai Indians' AND [T2].[bird_soccer_match_date] LIKE '2008%' GROUP BY [T2].[bird_soccer_match_id]) AS [T];

-- question_id=242 source_index=2029
SELECT [T1].[bird_soccer_team_name] FROM [bird_soccer_team] AS [T1] INNER JOIN [bird_soccer_match] AS [T2] ON [T1].[bird_soccer_team_id] = [T2].[bird_soccer_match_winner] INNER JOIN [bird_soccer_player_match] AS [T3] ON [T1].[bird_soccer_team_id] = [T3].[bird_soccer_team_id] INNER JOIN [bird_soccer_win_by] AS [T4] ON [T2].[bird_soccer_win_type] = [T4].[bird_soccer_win_id] WHERE [T2].[bird_soccer_match_id] = '335993' GROUP BY [T1].[bird_soccer_team_name];

-- question_id=243 source_index=2030
SELECT COUNT([T1].[bird_soccer_match_id]) FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_win_by] AS [T2] ON [T1].[bird_soccer_win_type] = [T2].[bird_soccer_win_id] WHERE [T2].[bird_soccer_win_type] = 'wickets';

-- question_id=244 source_index=2031
SELECT [T4].[bird_soccer_role_desc] FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_player_match] AS [T2] ON [T1].[bird_soccer_player_id] = [T2].[bird_soccer_player_id] INNER JOIN [bird_soccer_match] AS [T3] ON [T2].[bird_soccer_match_id] = [T3].[bird_soccer_match_id] INNER JOIN [bird_soccer_rolee] AS [T4] ON [T2].[bird_soccer_role_id] = [T4].[bird_soccer_role_id] INNER JOIN [bird_soccer_season] AS [T5] ON [T3].[bird_soccer_season_id] = [T5].[bird_soccer_season_id] WHERE [T1].[bird_soccer_player_name] = 'W Jaffer' AND [T5].[bird_soccer_season_year] = 2012;

-- question_id=245 source_index=2032
SELECT CASE WHEN COUNT([T2].[bird_soccer_man_of_the_match]) > 5 THEN [T1].[bird_soccer_player_name] ELSE NULL END FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_match] AS [T2] ON [T1].[bird_soccer_player_id] = [T2].[bird_soccer_man_of_the_match] INNER JOIN [bird_soccer_player_match] AS [T3] ON [T3].[bird_soccer_player_id] = [T1].[bird_soccer_player_id] INNER JOIN [bird_soccer_season] AS [T4] ON [T2].[bird_soccer_season_id] = [T4].[bird_soccer_season_id] WHERE [T4].[bird_soccer_season_year] = 2008 GROUP BY [T1].[bird_soccer_player_name];

-- question_id=246 source_index=2033
SELECT CAST(SUM(CASE WHEN [T2].[bird_soccer_country_name] = 'India' THEN 1 ELSE 0 END) AS FLOAT) / NULLIF(COUNT([T1].[bird_soccer_player_id]), 0) FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_country] AS [T2] ON [T1].[bird_soccer_country_name] = [T2].[bird_soccer_country_id] WHERE DATEPART(year, [T1].[bird_soccer_dob]) BETWEEN '1975' AND '1985';

-- question_id=247 source_index=2034
SELECT CAST(SUM(CASE WHEN [T2].[bird_soccer_batting_hand] = 'Left-hand bat' THEN 1 ELSE 0 END) AS FLOAT) * 100 / NULLIF(COUNT([T1].[bird_soccer_player_id]), 0) FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_batting_style] AS [T2] ON [T1].[bird_soccer_batting_hand] = [T2].[bird_soccer_batting_id];

-- question_id=248 source_index=2035
SELECT CAST(SUM(CASE WHEN [T1].[bird_soccer_win_type] = 1 THEN 1 ELSE 0 END) AS FLOAT) * 100 / NULLIF(COUNT([T1].[bird_soccer_win_type]), 0) FROM [bird_soccer_match] AS [T1] INNER JOIN [bird_soccer_win_by] AS [T2] ON [T1].[bird_soccer_win_type] = [T2].[bird_soccer_win_id];

-- question_id=249 source_index=2036
SELECT COUNT([bird_soccer_match_id]) FROM [bird_soccer_match] WHERE [bird_soccer_win_margin] = 7;

-- question_id=250 source_index=2037
SELECT COUNT([bird_soccer_player_id]) FROM [bird_soccer_player] WHERE DATEPART(year, [bird_soccer_dob]) BETWEEN '1970' AND '1975';

-- question_id=251 source_index=2038
SELECT [T1].[bird_soccer_team_name] FROM [bird_soccer_team] AS [T1] INNER JOIN [bird_soccer_match] AS [T2] ON [T1].[bird_soccer_team_id] = [T2].[bird_soccer_match_winner] WHERE [T2].[bird_soccer_win_margin] = 6 AND [T2].[bird_soccer_match_date] = '2009-04-26';

-- question_id=252 source_index=2039
SELECT [T1].[bird_soccer_team_name] FROM [bird_soccer_team] AS [T1] INNER JOIN [bird_soccer_match] AS [T2] ON [T1].[bird_soccer_team_id] = [T2].[bird_soccer_match_winner] INNER JOIN [bird_soccer_win_by] AS [T3] ON [T2].[bird_soccer_win_type] = [T3].[bird_soccer_win_id] WHERE [T2].[bird_soccer_match_id] = 419135;

-- question_id=253 source_index=2040
SELECT TOP 1 [T2].[bird_soccer_match_id] FROM [bird_soccer_venue] AS [T1] INNER JOIN [bird_soccer_match] AS [T2] ON [T1].[bird_soccer_venue_id] = [T2].[bird_soccer_venue_id] WHERE [T1].[bird_soccer_venue_name] = 'St George''s Park' ORDER BY [T2].[bird_soccer_win_margin] DESC;

-- question_id=254 source_index=2041
SELECT COUNT(*) FROM [bird_soccer_player] AS [T1] INNER JOIN [bird_soccer_country] AS [T2] ON [T1].[bird_soccer_country_name] = [T2].[bird_soccer_country_id] WHERE [T2].[bird_soccer_country_name] = 'Sri Lanka';

-- question_id=255 source_index=2042
SELECT [T2].[bird_soccer_player_name] FROM [bird_soccer_player_match] AS [T1] INNER JOIN [bird_soccer_player] AS [T2] ON [T1].[bird_soccer_player_id] = [T2].[bird_soccer_player_id] INNER JOIN [bird_soccer_rolee] AS [T3] ON [T1].[bird_soccer_role_id] = [T3].[bird_soccer_role_id] WHERE [T3].[bird_soccer_role_desc] = 'Captain' GROUP BY [T2].[bird_soccer_player_name];

-- question_id=256 source_index=2043
SELECT [T1].[bird_soccer_venue_name], [T3].[bird_soccer_team_name] FROM [bird_soccer_venue] AS [T1] INNER JOIN [bird_soccer_match] AS [T2] ON [T1].[bird_soccer_venue_id] = [T2].[bird_soccer_venue_id] INNER JOIN [bird_soccer_team] AS [T3] ON [T2].[bird_soccer_match_winner] = [T3].[bird_soccer_team_id] WHERE [T2].[bird_soccer_match_id] = 392194;

-- question_id=257 source_index=2044
SELECT CAST(SUM(CASE WHEN [T3].[bird_soccer_win_type] = 'wickets' THEN 1 ELSE 0 END) AS FLOAT) * 100 / NULLIF(COUNT([T3].[bird_soccer_win_type]), 0) FROM [bird_soccer_team] AS [T1] INNER JOIN [bird_soccer_match] AS [T2] ON [T1].[bird_soccer_team_id] = [T2].[bird_soccer_match_winner] INNER JOIN [bird_soccer_win_by] AS [T3] ON [T2].[bird_soccer_win_type] = [T3].[bird_soccer_win_id] WHERE [T1].[bird_soccer_team_name] = 'Delhi Daredevils';
