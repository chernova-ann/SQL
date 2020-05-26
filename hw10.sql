
USE vk;
SELECT * FROM users;
-- 1. Проанализировать какие запросы могут выполняться наиболее часто в процессе работы приложения и добавить необходимые индексы.

-- Поиск по тематике сообщества.
SELECT * FROM communities WHERE name LIKE '%non%';

CREATE INDEX communities_name_idx ON communities(name);


-- Поиск по ленте новостей созданных медиа за текущий месяц.
SELECT id, created_at FROM media;

SELECT * FROM media WHERE EXTRACT(MONTH FROM created_at) = '03' AND EXTRACT(YEAR FROM created_at) = '2020';

CREATE INDEX media_created_at_idx ON media(created_at);

-- Поиск людей среди друзей с подтвержденным статусом дружбы ().
SELECT friend_id, status_id FROM friendship;

SELECT * FROM friendship_statuses WHERE name = 'Confirmed'; -- status_id = 2

SELECT * FROM friendship WHERE status_id = 2;

CREATE INDEX friendship_status_id_idx ON friendship(status_id);

-- Поиск человека из людей, поставивших лайк за медиа.

SELECT user_id, target_type_id FROM likes;

SELECT * FROM likes WHERE user_id = 98 AND target_type_id = 3;  -- tagret_type_id = 3, name = 'media'

CREATE INDEX likes_user_id_target_tyoe_id_idx ON likes(user_id, target_type_id);

-- Поиск среди постов пользователя.

SELECT * FROM posts WHERE user_id = 3 AND post LIKE '%ex%';

CREATE INDEX posts_user_id_post_idx ON posts(user_id, post);  
-- SQL Error [1170] [42000]: BLOB/TEXT column 'post' used in key specification without a key length

DESC posts;


-- 2. Задание на оконные функции
-- Построить запрос, который будет выводить следующие столбцы:
-- имя группы
-- среднее количество пользователей в группах
-- самый молодой пользователь в группе
-- самый старший пользователь в группе
-- общее количество пользователей в группе
-- всего пользователей в системе
-- отношение в процентах (общее количество пользователей в группе / всего пользователей в системе) * 100

show tables;
SELECT c.name, count(cu.user_id) as total_com_users
FROM communities c
LEFT JOIN communities_users cu
ON c.id = cu.community_id
GROUP BY c.name; -- колиество пользователей в каждой группе


SELECT communities.name, communities_users.user_id, profiles.birthday
    FROM users
     LEFT JOIN communities_users 
        ON users.id = communities_users.user_id     
     LEFT JOIN communities 
        ON communities.id = communities_users.community_id
     LEFT JOIN profiles 
        ON communities_users.user_id = profiles.user_id
       ORDER BY communities.name;
       

SELECT DISTINCT 
  communities.name,
  FIRST_VALUE(profiles.user_id) OVER (PARTITION BY communities.name ORDER BY profiles.birthday) AS younger,
  MAX(profiles.birthday) OVER w AS younger_birth,
  FIRST_VALUE(profiles.user_id) OVER (PARTITION BY communities.name ORDER BY profiles.birthday DESC) AS older,
  MIN(profiles.birthday) OVER w AS older_birth,
  COUNT(communities_users.user_id) OVER w AS total_group_users,
  COUNT(users.id) OVER() AS total_system_users,
  COUNT(communities_users.user_id) OVER w / COUNT(users.id) OVER() * 100 AS "%%"
    FROM users
     LEFT JOIN communities_users 
        ON users.id = communities_users.user_id     
     LEFT JOIN communities 
        ON communities.id = communities_users.community_id
     LEFT JOIN profiles 
        ON communities_users.user_id = profiles.user_id
        WINDOW w AS (PARTITION BY communities.name);
