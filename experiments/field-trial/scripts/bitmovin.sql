/*
 * This script imports log data from Bitmovin, calculates a number of quality
 * criteria, and exports results to disk. Some criteria are defined as
 * distributions, others as relative percentagese.
 */

DROP TABLE IF EXISTS raw_data CASCADE;

-- Base directories

\set import_dir /home/magnuskl/experiments/imports/bitmovin
\set export_dir /home/magnuskl/experiments/exports/bitmovin

-- Import file(s)

\set raw_data :import_dir/bitmovin.csv

-- Export file(s)

\set states             :export_dir/states.csv
\set bitrates           :export_dir/bitrates.csv
\set startups           :export_dir/startups.csv
\set startups_quartiles :export_dir/startups_quartiles.csv
\set startups_outliers  :export_dir/startups_outliers.csv
\set startups_limits    :export_dir/startups_limits.csv
\set switches           :export_dir/switches.csv
\set switches_quartiles :export_dir/switches_quartiles.csv
\set switches_outliers  :export_dir/switches_outliers.csv
\set switches_limits    :export_dir/switches_limits.csv
\set stalls             :export_dir/stalls.csv
\set stalls_quartiles   :export_dir/stalls_quartiles.csv
\set stalls_outliers    :export_dir/stalls_outliers.csv
\set stalls_limits      :export_dir/stalls_limits.csv

-- Settings

\set period1_start '2019-10-18 14:00:00+02'
\set period1_end   '2019-10-18 22:00:00+02'
\set period2_start '2019-10-19 18:00:00+02'
\set period2_end   '2019-10-20 06:00:00+02'

-- Import data

CREATE TABLE raw_data (
    analytics_version             varchar,
    asn                           integer,
    audio_bitrate                 integer,
    autoplay                      boolean,
    browser                       varchar,
    browser_version_major         integer,
    browser_version_minor         integer,
    buffered                      integer,
    cdn_provider                  varchar,
    city                          varchar,
    client_time                   bigint,
    country                       varchar,
    custom_data_1                 uuid,
    custom_data_2                 varchar,
    custom_data_3                 varchar,
    custom_data_4                 varchar,
    custom_data_5                 varchar,
    custom_usr_id                 uuid,
    day                           bigint,
    device_type                   varchar,
    domain                        varchar,
    drm_load_time                 integer,
    drm_type                      varchar,
    dropped_frames                integer,
    duration                      integer,
    error_code                    integer,
    error_message                 varchar,
    experiment_name               varchar, -- Custom
    hour                          bigint,
    impression_id                 uuid,
    ip_address                    inet,
    is_casting                    boolean,
    is_live                       boolean,
    is_muted                      boolean,
    isp                           varchar,
    language                      varchar,
    m3u8_url                      varchar,
    minute                        bigint,
    month                         bigint,
    mpd_url                       varchar,
    operatingsystem               varchar,
    operatingsystem_version_major integer,
    operatingsystem_version_minor integer,
    page_load_time                integer,
    page_load_type                integer,
    path_                         varchar,
    paused                        integer,
    played                        integer,
    player                        varchar,
    player_key                    uuid,
    player_startuptime            integer,
    player_tech                   varchar,
    player_version                varchar,
    prog_url                      varchar,
    region                        varchar,
    screen_height                 integer,
    screen_width                  integer,
    seeked                        integer,
    size_                         varchar,
    startuptime                   integer,
    state                         varchar,
    stream_format                 varchar,
    time                          bigint,
    user_id                       uuid,
    video_bitrate                 integer,
    video_duration                integer,
    video_id                      varchar,
    video_playback_height         integer,
    video_playback_width          integer,
    video_startuptime             integer,
    video_title                   varchar,
    video_window_height           integer,
    video_window_width            integer,
    videotime_end                 integer,
    videotime_start               integer,
    segments_download_count       integer,
    segments_download_time        integer,
    segments_download_size        integer,
    segment_name                  varchar,
    platform                      varchar
);

COPY raw_data FROM :'raw_data' CSV HEADER;

-- Preprocess data

UPDATE raw_data
SET experiment_name = 'Berlin I'
WHERE to_timestamp(time / 1000) BETWEEN :'period1_start' AND :'period1_end';

UPDATE raw_data
SET experiment_name = 'Berlin II'
WHERE to_timestamp(time / 1000) BETWEEN :'period2_start' AND :'period2_end';

DELETE FROM raw_data
WHERE experiment_name <> 'Berlin I'
  AND experiment_name <> 'Berlin II';

-- Relative duration of player states excluding pauses (percent)

CREATE VIEW states AS
    WITH totals AS (
        SELECT experiment_name, SUM(duration) AS duration
        FROM raw_data
        WHERE state <> 'pause'
        GROUP BY experiment_name
    ), states AS (
        SELECT experiment_name, state, SUM(duration) AS duration
        FROM raw_data
        WHERE state <> 'pause'
        GROUP BY experiment_name, state
    )
    SELECT totals.experiment_name,
           state,
           round(100 * states.duration / totals.duration :: numeric, 3)
               AS percent
    FROM totals, states
    WHERE totals.experiment_name = states.experiment_name
    ORDER BY experiment_name;

-- Relative duration of bit rate levels excluding null level (percent)

CREATE VIEW bitrates AS
    WITH totals AS (
        SELECT experiment_name, SUM(duration) AS duration
        FROM raw_data
        WHERE state = 'playing'
          AND video_bitrate <> 0
        GROUP BY experiment_name
    ), bitrates AS (
        SELECT experiment_name, video_bitrate / 1000000 * 1000000 AS bitrate,
               SUM(duration) AS duration
        FROM raw_data
        WHERE state = 'playing'
          AND video_bitrate <> 0
        GROUP BY experiment_name, bitrate
    )
    SELECT totals.experiment_name,
           bitrate,
           round(100 * bitrates.duration / totals.duration :: numeric, 3)
               AS percent
    FROM totals, bitrates
    WHERE totals.experiment_name = bitrates.experiment_name
    ORDER BY experiment_name;

-- Start-up time (seconds)

CREATE VIEW startups AS
    SELECT experiment_name,
           impression_id,
           round(startuptime / 1000 :: numeric, 3) AS startuptime
    FROM raw_data
    WHERE startuptime > 0
    ORDER BY experiment_name;

CREATE VIEW startups_quartiles AS
    SELECT experiment_name,
           percentile_cont(0.25) WITHIN GROUP (ORDER BY startuptime) AS q1,
           percentile_cont(0.5) WITHIN GROUP (ORDER BY startuptime) AS median_,
           percentile_cont(0.75) WITHIN GROUP (ORDER BY startuptime) AS q3
    FROM startups
    GROUP BY experiment_name
    ORDER BY experiment_name;

CREATE VIEW startups_inliers AS
    SELECT startups.experiment_name, impression_id, startuptime
    FROM startups, startups_quartiles
    WHERE startups.experiment_name = startups_quartiles.experiment_name
          AND startups.startuptime
          BETWEEN q1 - 1.5 * (q3 - q1) AND q3 + 1.5 * (q3 - q1)
    ORDER BY experiment_name;
    
CREATE VIEW startups_outliers AS
    SELECT startups.experiment_name, impression_id, startuptime
    FROM startups, startups_quartiles
    WHERE startups.experiment_name = startups_quartiles.experiment_name
          AND startups.startuptime
          NOT BETWEEN q1 - 1.5 * (q3 - q1) AND q3 + 1.5 * (q3 - q1)
    ORDER BY experiment_name;

CREATE VIEW startups_limits AS
    SELECT startups.experiment_name,
           MIN(startups.startuptime) AS min_,
           MIN(startups_inliers.startuptime) AS low,
           MAX(startups_inliers.startuptime) AS high,
           MAX(startups.startuptime) AS max_
    FROM startups, startups_inliers
    WHERE startups.experiment_name = startups_inliers.experiment_name
    GROUP BY startups.experiment_name
    ORDER BY experiment_name;

-- Frequency of quality switches exc. < 1 min (n per minute)

CREATE VIEW switches AS
    WITH totals AS (
        SELECT experiment_name, impression_id, SUM(duration) AS duration
        FROM raw_data
        WHERE duration >= 60000
        GROUP BY experiment_name, impression_id
    ), switches AS (
        SELECT experiment_name, impression_id, COUNT(*) AS n
        FROM raw_data
        WHERE state = 'qualitychange'
        GROUP BY experiment_name, impression_id
    )
    SELECT totals.experiment_name,
           totals.impression_id,
           round(COALESCE(60000 * n / duration :: numeric, 0.000), 3) AS freq
    FROM totals LEFT JOIN switches
    ON totals.experiment_name = switches.experiment_name
    AND totals.impression_id = switches.impression_id
    ORDER BY experiment_name;

CREATE VIEW switches_quartiles AS
    SELECT experiment_name,
           percentile_cont(0.25) WITHIN GROUP (ORDER BY freq) AS q1,
           percentile_cont(0.5)  WITHIN GROUP (ORDER BY freq) AS median_,
           percentile_cont(0.75) WITHIN GROUP (ORDER BY freq) AS q3
    FROM switches
    GROUP BY experiment_name
    ORDER BY experiment_name;

CREATE VIEW switches_inliers AS
    SELECT switches.experiment_name, impression_id, freq
    FROM switches, switches_quartiles
    WHERE switches.experiment_name = switches_quartiles.experiment_name
      AND freq BETWEEN q1 - 1.5 * (q3 - q1) AND q3 + 1.5 * (q3 - q1)
    ORDER BY experiment_name;

CREATE VIEW switches_outliers AS
    SELECT switches.experiment_name, impression_id, freq
    FROM switches, switches_quartiles
    WHERE switches.experiment_name = switches_quartiles.experiment_name
      AND freq NOT BETWEEN q1 - 1.5 * (q3 - q1) AND q3 + 1.5 * (q3 - q1)
    ORDER BY experiment_name;

CREATE VIEW switches_limits AS
    SELECT switches.experiment_name,
           MIN(switches.freq) AS min_,
           MIN(switches_inliers.freq) AS low,
           MAX(switches_inliers.freq) AS high,
           MAX(switches.freq) AS max_
    FROM switches, switches_inliers
    WHERE switches.experiment_name = switches_inliers.experiment_name
    GROUP BY switches.experiment_name
    ORDER BY experiment_name;

-- Frequency of stalls exc. < 1 min (n per minute)

CREATE VIEW stalls AS
    WITH totals AS (
        SELECT experiment_name, impression_id, SUM(duration) AS duration
        FROM raw_data
        WHERE duration >= 60000
        GROUP BY experiment_name, impression_id
    ), stalls AS (
        SELECT experiment_name, impression_id, COUNT(*) AS n
        FROM raw_data
        WHERE state = 'rebuffering'
        GROUP BY experiment_name, impression_id
    )
    SELECT totals.experiment_name,
           totals.impression_id,
           round(COALESCE(60000 * n / duration :: numeric, 0.000), 3) AS freq
    FROM totals LEFT JOIN stalls
    ON  totals.experiment_name = stalls.experiment_name
    AND totals.impression_id = stalls.impression_id
    ORDER BY experiment_name;

CREATE VIEW stalls_quartiles AS
    SELECT experiment_name,
           percentile_cont(0.25) WITHIN GROUP (ORDER BY freq) AS q1,
           percentile_cont(0.5)  WITHIN GROUP (ORDER BY freq) AS median_,
           percentile_cont(0.75) WITHIN GROUP (ORDER BY freq) AS q3
    FROM stalls
    GROUP BY experiment_name
    ORDER BY experiment_name;

CREATE VIEW stalls_inliers AS
    SELECT stalls.experiment_name, impression_id, freq
    FROM stalls, stalls_quartiles
    WHERE stalls.experiment_name = stalls_quartiles.experiment_name
      AND freq BETWEEN q1 - 1.5 * (q3 - q1) AND q3 + 1.5 * (q3 - q1)
    ORDER BY experiment_name;

CREATE VIEW stalls_outliers AS
    SELECT stalls.experiment_name, impression_id, freq
    FROM stalls, stalls_quartiles
    WHERE stalls.experiment_name = stalls_quartiles.experiment_name
      AND freq NOT BETWEEN q1 - 1.5 * (q3 - q1) AND q3 + 1.5 * (q3 - q1);

CREATE VIEW stalls_limits AS
    SELECT stalls.experiment_name,
           MIN(stalls.freq) AS min_,
           MIN(stalls_inliers.freq) AS low,
           MAX(stalls_inliers.freq) AS high,
           MAX(stalls.freq) AS max_
    FROM stalls, stalls_inliers
    WHERE stalls.experiment_name = stalls_inliers.experiment_name
    GROUP BY stalls.experiment_name
    ORDER BY experiment_name;

-- Export data

COPY (SELECT * FROM states)             TO :'states'             CSV HEADER;
COPY (SELECT * FROM bitrates)           TO :'bitrates'           CSV HEADER;
COPY (SELECT * FROM startups)           TO :'startups'           CSV HEADER;
COPY (SELECT * FROM startups_quartiles) TO :'startups_quartiles' CSV HEADER;
COPY (SELECT * FROM startups_outliers)  TO :'startups_outliers'  CSV HEADER;
COPY (SELECT * FROM startups_limits)    TO :'startups_limits'    CSV HEADER;
COPY (SELECT * FROM switches)           TO :'switches'           CSV HEADER;
COPY (SELECT * FROM switches_quartiles) TO :'switches_quartiles' CSV HEADER;
COPY (SELECT * FROM switches_outliers)  TO :'switches_outliers'  CSV HEADER;
COPY (SELECT * FROM switches_limits)    TO :'switches_limits'    CSV HEADER;
COPY (SELECT * FROM stalls)             TO :'stalls'             CSV HEADER;
COPY (SELECT * FROM stalls_quartiles)   TO :'stalls_quartiles'   CSV HEADER;
COPY (SELECT * FROM stalls_outliers)    TO :'stalls_outliers'    CSV HEADER;
COPY (SELECT * FROM stalls_limits)      TO :'stalls_limits'      CSV HEADER;
