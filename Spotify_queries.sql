
use spotifydb

#drop table if exists spotify

#alter table
#spotify_project rename spotify

# basic exploratio

select count(*) from spotify

select * from spotify;

select distinct album from spotify;

select count(distinct album) from spotify;

select count(distinct artist) from spotify;

select distinct album_type from spotify;

select sum(duration_min/60) as total_time_hour from spotify;

select max(duration_min) from spotify;
select min(duration_min) from spotify;

select count(distinct channel) from spotify

select most_playedon, count(distinct channel) from spotify
group by most_playedon order by count(distinct channel)


# Question_1 --> retrieve the names of all tracks that have more than 1 billion streams.
select track, views from spotify
where views > 1000000000;

#Question_2 --> List all albums along with their respective artists.
select artist, album from spotify;

#Question_3 --> Get the total number of comments for tracks where licensed = True
select licensed, count(comments) as total_comments from spotify
group by licensed
having licensed = 'True';

#Question_4 --> Find all tracks that belong to the album type single
select track, album_type from spotify
where album_type = 'single'

#Question_5 --> Count the total number of tracks by each artists.
select artist, count(*) No_of_track from spotify
group by artist order by No_of_track desc;


#------------------------------------------------------------------------------------------------------------#

#Question_6 --> Calculate the average daceability of tracks in each album
select track, album, avg(Danceability) as avg_danceability from spotify
group by track, album order by avg_danceability desc;

#Question_7 --> find the top 5 tracks with the higest energy values
select track, max(Energy) as highest_energy from spotify
group by track order by highest_energy desc limit 5;

#-------------------------------OR-----------------------------------#

with cte as (select track, max(Energy) as highest_energy from spotify 
group by track)
select track, highest_energy from cte order by highest_energy desc limit 5

#---------------------------------OR------------------------------------#
with cte as(
select track, energy, row_number() over(partition by track order by energy desc) as highest_energy
from spotify  order by energy desc limit 5)
select track, energy from cte
order by energy desc limit 5

#Question_8 --> List all tracks along with their views and likes where official_video = True
select track,official_video, sum(views) as total_views, sum(likes) as total_likes from spotify
group by track, official_video having official_video = 'True'
order by total_views desc

#Question_9 --> For each album, calculate the total views of all associated tracks
select album, track, sum(views) as total_views from spotify
group by album, track order by total_views desc;

#Question_10 --> Retrieve the track names that have been streamed on spotify more than YouTube
with cte as(
SELECT track,
    coalesce(sum(CASE WHEN most_playedon = 'spotify' THEN stream END),0) AS spotify_count,
    coalesce(sum(CASE WHEN most_playedon = 'youtube' THEN stream END),0) AS youtube_count
FROM spotify
GROUP BY track
HAVING COUNT(CASE WHEN most_playedon = 'spotify' THEN 1 END) > 
COUNT(CASE WHEN most_playedon = 'youtube' THEN 1 END)
order by spotify_count desc
)
select track, spotify_count from cte;

#---------------------------------------OR-------------------------------------------#

select track, spotify_count, youtube_count from 
( select track,
					coalesce(sum(case when most_playedon = 'spotify' then stream end),0) as spotify_count,
					coalesce(sum(case when most_playedon = 'youtube' then stream end),0) as youtube_count
                    from spotify group by track
                    ) as track_count
where spotify_count > youtube_count and youtube_count <> 0
order by spotify_count desc;




#---------------------------------------------------------------------------------------------------------


# Question_11 --> Find the top 3 most-viewed tracks for each artist using window functions.
with cte as(
select track, artist, views,
rank() over(partition by artist order by views desc) as most_viewed_track
	from spotify
    )
    select track, artist, views from cte
    where most_viewed_track <= 3
   order by artist, track limit 9
   
   WITH ranked_tracks AS (
    SELECT track, artist, views,
        RANK() OVER (PARTITION BY artist ORDER BY views DESC) AS rnk
    FROM spotify
)
SELECT track, artist, views
FROM ranked_tracks
WHERE rnk <= 3
ORDER BY artist, rnk;

    
    select  distinct track, artist, sum(views) from spotify
    group by track, artist order by sum(views) desc limit 3
        
# Question_12 --> Write a query to find track where the liveness score is above the average.
select track, liveness from spotify where 
liveness > (select avg(liveness) from spotify)
order by liveness desc


#Question_13 --> Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
select * from spotify

WITH cte AS (
    SELECT album,
           MAX(energy) AS max_energy,
           MIN(energy) AS min_energy
    FROM spotify
    GROUP BY album
)
SELECT album, max_energy - min_energy AS energy_diff
FROM cte
ORDER BY energy_diff DESC;

# ---------------------------------------OR------------------------------------------#

with cte as (
select album, energy, rank() over(partition by album order by energy desc) as max_rank,
		      rank() over(partition by album order by energy asc) as min_rank
              from spotify
              )
select album, max(case when max_rank = 1 then energy end) - 
min(case when min_rank = 1 then energy end) as energy_diff
from cte group by album order by energy_diff desc;


              


















