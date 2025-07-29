-- Well-Normalized Sports Database Schema

-- Countries table (1NF normalization - separate countries)
CREATE TABLE countries (
    pk_country_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    country_name VARCHAR(100) NOT NULL UNIQUE,
    country_code VARCHAR(3) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Competitions table
CREATE TABLE competitions (
    pk_competition_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    competition_name VARCHAR(200) NOT NULL,
    fk_country_id UUID NOT NULL,
    competition_type VARCHAR(50), -- league, cup, international, etc.
    season_format VARCHAR(50), -- annual, biannual, etc.
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_competitions_country 
        FOREIGN KEY (fk_country_id) REFERENCES countries(pk_country_id),
    CONSTRAINT uk_competition_name_country 
        UNIQUE (competition_name, fk_country_id)
);

-- Teams table
CREATE TABLE teams (
    pk_team_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    team_name VARCHAR(200) NOT NULL,
    fk_country_id UUID NOT NULL,
    founded_year INTEGER,
    team_code VARCHAR(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_teams_country 
        FOREIGN KEY (fk_country_id) REFERENCES countries(pk_country_id),
    CONSTRAINT uk_team_name_country 
        UNIQUE (team_name, fk_country_id)
);

-- Seasons table (separate seasons for better normalization)
CREATE TABLE seasons (
    pk_season_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    season_name VARCHAR(20) NOT NULL, -- e.g., "2023-24", "2024"
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT uk_season_name UNIQUE (season_name),
    CONSTRAINT chk_season_dates CHECK (end_date > start_date)
);

-- Competition seasons (many-to-many relationship)
CREATE TABLE competition_seasons (
    pk_competition_season_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fk_competition_id UUID NOT NULL,
    fk_season_id UUID NOT NULL,
    total_matchweeks INTEGER,
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_comp_seasons_competition 
        FOREIGN KEY (fk_competition_id) REFERENCES competitions(pk_competition_id),
    CONSTRAINT fk_comp_seasons_season 
        FOREIGN KEY (fk_season_id) REFERENCES seasons(pk_season_id),
    CONSTRAINT uk_competition_season 
        UNIQUE (fk_competition_id, fk_season_id)
);

-- Team participations in competition seasons
CREATE TABLE team_participations (
    pk_participation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fk_competition_season_id UUID NOT NULL,
    fk_team_id UUID NOT NULL,
    registration_date DATE DEFAULT CURRENT_DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_participations_comp_season 
        FOREIGN KEY (fk_competition_season_id) REFERENCES competition_seasons(pk_competition_season_id),
    CONSTRAINT fk_participations_team 
        FOREIGN KEY (fk_team_id) REFERENCES teams(pk_team_id),
    CONSTRAINT uk_team_competition_season 
        UNIQUE (fk_competition_season_id, fk_team_id)
);

-- Venues table (stadiums/grounds)
CREATE TABLE venues (
    pk_venue_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    venue_name VARCHAR(200) NOT NULL,
    fk_country_id UUID NOT NULL,
    city VARCHAR(100),
    capacity INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_venues_country 
        FOREIGN KEY (fk_country_id) REFERENCES countries(pk_country_id),
    CONSTRAINT uk_venue_name_city 
        UNIQUE (venue_name, city)
);

-- Match information table (improved)
CREATE TABLE matches (
    pk_match_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fk_competition_season_id UUID NOT NULL,
    matchweek VARCHAR(50), -- e.g., "Matchweek 1", "Quarter-final"
    matchweek_number INTEGER,
    kick_off TIMESTAMP NOT NULL,
    fk_home_team_id UUID NOT NULL,
    fk_away_team_id UUID NOT NULL,
    fk_venue_id UUID,
    match_status VARCHAR(20) DEFAULT 'scheduled', -- scheduled, in_progress, completed, postponed, cancelled
    home_score INTEGER DEFAULT 0,
    away_score INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_matches_comp_season 
        FOREIGN KEY (fk_competition_season_id) REFERENCES competition_seasons(pk_competition_season_id),
    CONSTRAINT fk_matches_home_team 
        FOREIGN KEY (fk_home_team_id) REFERENCES teams(pk_team_id),
    CONSTRAINT fk_matches_away_team 
        FOREIGN KEY (fk_away_team_id) REFERENCES teams(pk_team_id),
    CONSTRAINT fk_matches_venue 
        FOREIGN KEY (fk_venue_id) REFERENCES venues(pk_venue_id),
    CONSTRAINT chk_different_teams 
        CHECK (fk_home_team_id != fk_away_team_id),
    CONSTRAINT chk_scores_non_negative 
        CHECK (home_score >= 0 AND away_score >= 0)
);

-- Action types table (better naming)
CREATE TABLE action_types (
    pk_action_type_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    action_name VARCHAR(100) NOT NULL UNIQUE,
    action_category VARCHAR(50), -- goal, card, substitution, etc.
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Players table (for better action attribution)
CREATE TABLE players (
    pk_player_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    fk_nationality_id UUID,
    position VARCHAR(50),
    jersey_number INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_players_nationality 
        FOREIGN KEY (fk_nationality_id) REFERENCES countries(pk_country_id)
);

CREATE TABLE team_season_competition_stats (
    pk_team_season_competition_stats UUID PRIMARY KEY  DEFAULT  gen_random_uuid(),
    created_at timestamp default  current_timestamp,
    updated_at timestamp default  current_timestamp,
    fk_team_id UUID not null,
    fk_competition_season_id UUID not null,
    home_goals_season integer,
    away_goals_season integer,
    average_goals_season float,
    first_half_season_goals_scored float,
    second_half_season_goals_scored float,
    average_season_first_half_goals_scored float,
    average_season_second_half_goals_scored float,
    first_half_home_game_first_half_goals_scored float,
    second_half_home_season_goals_scored float,
    average_home_game_first_half_goals_scored float,
    average_home_game_second_half_goals_scored float,
    first_half_away_season_goals_scored integer,
    second_half_away_season_goals_scored integer,
    average_away_game_first_half_goals_scored float,
    average_away_game_second_half_goals_scored float,
    home_goals_conceded_season integer,
    away_goals_conceded_season integer,
    first_half_home_goals_conceded integer,
    second_half_home_goals_conceded integer,
    first_half_away_goals_conceded integer,
    second_half_away_goals_conceded integer,
    average_home_game_goals_conceded float,
    average_away_game_goals_conceded float,
    average_first_half_home_goals_conceded float,
    average_second_half_home_goals_conceded float,
    average_first_half_away_goals_conceded float,
    average_second_half_away_goals_conceded float

);

-- -- Player contracts (team-player relationships with time periods)
-- create table player_contracts (
--     pk_contract_id uuid primary key default gen_random_uuid(),
--     fk_player_id uuid not null,
--     fk_team_id uuid not null,
--     contract_start date not null,
--     contract_end date,
--     jersey_number integer,
--     is_active boolean default true,
--     created_at timestamp default current_timestamp,
--
--     constraint fk_contracts_player
--         foreign key (fk_player_id) references players(pk_player_id),
--     constraint fk_contracts_team
--         foreign key (fk_team_id) references teams(pk_team_id),
--     constraint chk_contract_dates
--         check (contract_end is null or contract_end >= contract_start)
-- );

-- Match events (renamed from match_actions for clarity)
CREATE TABLE match_events (
    pk_match_event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fk_match_id UUID NOT NULL,
    fk_action_type_id UUID NOT NULL,
    fk_team_id UUID NOT NULL,
    fk_player_id UUID,
    fk_secondary_player_id UUID, -- for substitutions, assists, etc.
    event_minute INTEGER,
    additional_time INTEGER DEFAULT 0,
    half_period VARCHAR(20) NOT NULL, -- 1st_half, 2nd_half, extra_time_1, extra_time_2, penalty_shootout
    event_description TEXT,
    x_coordinate DECIMAL(5,2), -- field position coordinates
    y_coordinate DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_events_match 
        FOREIGN KEY (fk_match_id) REFERENCES matches(pk_match_id),
    CONSTRAINT fk_events_action_type 
        FOREIGN KEY (fk_action_type_id) REFERENCES action_types(pk_action_type_id),
    CONSTRAINT fk_events_team 
        FOREIGN KEY (fk_team_id) REFERENCES teams(pk_team_id),
    CONSTRAINT fk_events_player 
        FOREIGN KEY (fk_player_id) REFERENCES players(pk_player_id),
    CONSTRAINT fk_events_secondary_player 
        FOREIGN KEY (fk_secondary_player_id) REFERENCES players(pk_player_id),
    CONSTRAINT chk_event_minute 
        CHECK (event_minute >= 0 AND event_minute <= 150),
    CONSTRAINT chk_additional_time 
        CHECK (additional_time >= 0),
    CONSTRAINT chk_coordinates 
        CHECK (x_coordinate IS NULL OR (x_coordinate >= 0 AND x_coordinate <= 100)),
    CONSTRAINT chk_coordinates_y 
        CHECK (y_coordinate IS NULL OR (y_coordinate >= 0 AND y_coordinate <= 100))
);

-- Indexes for better performance
CREATE INDEX idx_matches_kick_off ON matches(kick_off);
CREATE INDEX idx_matches_competition_season ON matches(fk_competition_season_id);
CREATE INDEX idx_matches_teams ON matches(fk_home_team_id, fk_away_team_id);
CREATE INDEX idx_match_events_match ON match_events(fk_match_id);
CREATE INDEX idx_match_events_minute ON match_events(event_minute);
-- CREATE INDEX idx_player_contracts_active ON player_contracts(fk_team_id, is_active) WHERE is_active = TRUE;

-- Sample data for action types
INSERT INTO action_types (action_name, action_category, description) VALUES
('Goal', 'scoring', 'Ball crosses the goal line'),
('Yellow Card', 'disciplinary', 'Caution given to player'),
('Red Card', 'disciplinary', 'Player sent off'),
('Substitution', 'tactical', 'Player replacement'),
('Corner Kick', 'set_piece', 'Corner kick awarded'),
('Free Kick', 'set_piece', 'Free kick awarded'),
('Penalty', 'set_piece', 'Penalty kick awarded'),
('Offside', 'violation', 'Offside offense'),
('Foul', 'violation', 'Foul committed');


-- Insert countries from A to N with their ISO 3166-1 alpha-3 codes
INSERT INTO countries (country_name, country_code) VALUES
-- A
('Afghanistan', 'AFG'),
('Albania', 'ALB'),
('Algeria', 'DZA'),
('Andorra', 'AND'),
('Angola', 'AGO'),
('Antigua and Barbuda', 'ATG'),
('Argentina', 'ARG'),
('Armenia', 'ARM'),
('Australia', 'AUS'),
('Austria', 'AUT'),
('Azerbaijan', 'AZE'),

-- B
('Bahamas', 'BHS'),
('Bahrain', 'BHR'),
('Bangladesh', 'BGD'),
('Barbados', 'BRB'),
('Belarus', 'BLR'),
('Belgium', 'BEL'),
('Belize', 'BLZ'),
('Benin', 'BEN'),
('Bhutan', 'BTN'),
('Bolivia', 'BOL'),
('Bosnia and Herzegovina', 'BIH'),
('Botswana', 'BWA'),
('Brazil', 'BRA'),
('Brunei', 'BRN'),
('Bulgaria', 'BGR'),
('Burkina Faso', 'BFA'),
('Burundi', 'BDI'),

-- C
('Cabo Verde', 'CPV'),
('Cambodia', 'KHM'),
('Cameroon', 'CMR'),
('Canada', 'CAN'),
('Central African Republic', 'CAF'),
('Chad', 'TCD'),
('Chile', 'CHL'),
('China', 'CHN'),
('Colombia', 'COL'),
('Comoros', 'COM'),
('Congo', 'COG'),
('Democratic Republic of the Congo', 'COD'),
('Costa Rica', 'CRI'),
('Croatia', 'HRV'),
('Cuba', 'CUB'),
('Cyprus', 'CYP'),
('Czech Republic', 'CZE'),
('Côte d''Ivoire', 'CIV'),

-- D
('Denmark', 'DNK'),
('Djibouti', 'DJI'),
('Dominica', 'DMA'),
('Dominican Republic', 'DOM'),

-- E
('Ecuador', 'ECU'),
('Egypt', 'EGY'),
('El Salvador', 'SLV'),
('Equatorial Guinea', 'GNQ'),
('Eritrea', 'ERI'),
('Estonia', 'EST'),
('Eswatini', 'SWZ'),
('Ethiopia', 'ETH'),

-- F
('Fiji', 'FJI'),
('Finland', 'FIN'),
('France', 'FRA'),

-- G
('Gabon', 'GAB'),
('Gambia', 'GMB'),
('Georgia', 'GEO'),
('Germany', 'DEU'),
('Ghana', 'GHA'),
('Greece', 'GRC'),
('Grenada', 'GRD'),
('Guatemala', 'GTM'),
('Guinea', 'GIN'),
('Guinea-Bissau', 'GNB'),
('Guyana', 'GUY'),

-- H
('Haiti', 'HTI'),
('Honduras', 'HND'),
('Hungary', 'HUN'),

-- I
('Iceland', 'ISL'),
('India', 'IND'),
('Indonesia', 'IDN'),
('Iran', 'IRN'),
('Iraq', 'IRQ'),
('Ireland', 'IRL'),
('Israel', 'ISR'),
('Italy', 'ITA'),

-- J
('Jamaica', 'JAM'),
('Japan', 'JPN'),
('Jordan', 'JOR'),

-- K
('Kazakhstan', 'KAZ'),
('Kenya', 'KEN'),
('Kiribati', 'KIR'),
('Kuwait', 'KWT'),
('Kyrgyzstan', 'KGZ'),

-- L
('Laos', 'LAO'),
('Latvia', 'LVA'),
('Lebanon', 'LBN'),
('Lesotho', 'LSO'),
('Liberia', 'LBR'),
('Libya', 'LBY'),
('Liechtenstein', 'LIE'),
('Lithuania', 'LTU'),
('Luxembourg', 'LUX'),

-- M
('Madagascar', 'MDG'),
('Malawi', 'MWI'),
('Malaysia', 'MYS'),
('Maldives', 'MDV'),
('Mali', 'MLI'),
('Malta', 'MLT'),
('Marshall Islands', 'MHL'),
('Mauritania', 'MRT'),
('Mauritius', 'MUS'),
('Mexico', 'MEX'),
('Micronesia', 'FSM'),
('Moldova', 'MDA'),
('Monaco', 'MCO'),
('Mongolia', 'MNG'),
('Montenegro', 'MNE'),
('Morocco', 'MAR'),
('Mozambique', 'MOZ'),
('Myanmar', 'MMR'),

-- N
('Namibia', 'NAM'),
('Nauru', 'NRU'),
('Nepal', 'NPL'),
('Netherlands', 'NLD'),
('New Zealand', 'NZL'),
('Nicaragua', 'NIC'),
('Niger', 'NER'),
('Nigeria', 'NGA'),
('North Korea', 'PRK'),
('North Macedonia', 'MKD'),
('Norway', 'NOR'),

-- O
('Oman', 'OMN'),

-- P
('Pakistan', 'PAK'),
('Palau', 'PLW'),
('Palestine', 'PSE'),
('Panama', 'PAN'),
('Papua New Guinea', 'PNG'),
('Paraguay', 'PRY'),
('Peru', 'PER'),
('Philippines', 'PHL'),
('Poland', 'POL'),
('Portugal', 'PRT'),

-- Q
('Qatar', 'QAT'),

-- R
('Romania', 'ROU'),
('Russia', 'RUS'),
('Rwanda', 'RWA'),

-- S
('Saint Kitts and Nevis', 'KNA'),
('Saint Lucia', 'LCA'),
('Saint Vincent and the Grenadines', 'VCT'),
('Samoa', 'WSM'),
('San Marino', 'SMR'),
('Sao Tome and Principe', 'STP'),
('Saudi Arabia', 'SAU'),
('Senegal', 'SEN'),
('Serbia', 'SRB'),
('Seychelles', 'SYC'),
('Sierra Leone', 'SLE'),
('Singapore', 'SGP'),
('Slovakia', 'SVK'),
('Slovenia', 'SVN'),
('Solomon Islands', 'SLB'),
('Somalia', 'SOM'),
('South Africa', 'ZAF'),
('South Korea', 'KOR'),
('South Sudan', 'SSD'),
('Spain', 'ESP'),
('Sri Lanka', 'LKA'),
('Sudan', 'SDN'),
('Suriname', 'SUR'),
('Sweden', 'SWE'),
('Switzerland', 'CHE'),
('Syria', 'SYR'),

-- T
('Tajikistan', 'TJK'),
('Tanzania', 'TZA'),
('Thailand', 'THA'),
('Timor-Leste', 'TLS'),
('Togo', 'TGO'),
('Tonga', 'TON'),
('Trinidad and Tobago', 'TTO'),
('Tunisia', 'TUN'),
('Turkey', 'TUR'),
('Turkmenistan', 'TKM'),
('Tuvalu', 'TUV'),

-- U
('Uganda', 'UGA'),
('Ukraine', 'UKR'),
('United Arab Emirates', 'ARE'),
('United Kingdom', 'GBR'),
('United States', 'USA'),
('Uruguay', 'URY'),
('Uzbekistan', 'UZB'),

-- V
('Vanuatu', 'VUT'),
('Vatican City', 'VAT'),
('Venezuela', 'VEN'),
('Vietnam', 'VNM'),

-- Y
('Yemen', 'YEM'),

-- Z
('Zambia', 'ZMB'),
('Zimbabwe', 'ZWE');

-- Create indexes for better performance
CREATE INDEX idx_countries_name ON countries(country_name);
CREATE INDEX idx_countries_code ON countries(country_code);


