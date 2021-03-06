-- Votes Report
select    votes.*,
          users.*,
          session_aggr.cnt AS first_author_count,
          session_aggr_2.cnt AS second_author_count,
          comment_aggr.cnt AS comment_count
from      votes
inner join
          users
          on users.id = votes.user_id
left outer join (
            SELECT author_id, count(*) AS cnt
            FROM sessions
            GROUP BY author_id
          ) AS session_aggr
          ON session_aggr.author_id = users.id
left outer join (
            SELECT second_author_id, count(*) AS cnt
            FROM sessions
            GROUP BY second_author_id
          ) AS session_aggr_2
          ON session_aggr_2.second_author_id = users.id
left outer join (
            SELECT user_id, count(*) AS cnt
            FROM comments
            GROUP BY user_id
          ) AS comment_aggr
          ON comment_aggr.user_id = users.id
where     user_ip IN (
            select user_ip from votes
            group by user_ip
            having count(user_ip) > 1
          )
order by  votes.user_ip,
          votes.created_at

-- Reviews Report
select    sessions.id,
          sessions.title,
          first_author.first_name,
          first_author.last_name,
          second_author.first_name,
          second_author.last_name,
          tracks.title,
          session_types.title,
          audience_levels.title,
          sessions.audience_limit,
          sessions.duration_mins,
          strong_accepts.cnt AS strong_accept,
          weak_accepts.cnt AS weak_accept,
          weak_rejects.cnt AS weak_reject,
          strong_rejects.cnt AS strong_reject,
          reviews.*,
          reviewer.first_name,
          reviewer.last_name
from      sessions
inner join
          users AS first_author
          on first_author.id = sessions.author_id
left outer join
          users AS second_author
          on second_author.id = sessions.second_author_id
inner join
          tracks
          on tracks.id = sessions.track_id
inner join
          session_types
          on session_types.id = sessions.session_type_id
inner join
          audience_levels
          on audience_levels.id = sessions.audience_level_id
left outer join (
            SELECT session_id, count(*) AS cnt
            FROM reviews
            WHERE recommendation_id = 4
            GROUP BY session_id
          ) AS strong_accepts
          ON strong_accepts.session_id = sessions.id
left outer join (
            SELECT session_id, count(*) AS cnt
            FROM reviews
            WHERE recommendation_id = 3
            GROUP BY session_id
          ) AS weak_accepts
          ON weak_accepts.session_id = sessions.id
left outer join (
            SELECT session_id, count(*) AS cnt
            FROM reviews
            WHERE recommendation_id = 2
            GROUP BY session_id
          ) AS weak_rejects
          ON weak_rejects.session_id = sessions.id
left outer join (
            SELECT session_id, count(*) AS cnt
            FROM reviews
            WHERE recommendation_id = 1
            GROUP BY session_id
          ) AS strong_rejects
          ON strong_rejects.session_id = sessions.id
inner join reviews ON reviews.session_id = sessions.id
inner join
          users AS reviewer
          on reviewer.id = reviews.reviewer_id
where     sessions.state <> 'cancelled'
order by sessions.id