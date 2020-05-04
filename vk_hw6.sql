
-- 1. Создать все необходимые внешние ключи и диаграмму отношений.
-- 2. Создать и заполнить таблицы лайков и постов.


USE vk;

DROP TABLE IF EXISTS likes;
CREATE TABLE likes (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  target_id INT UNSIGNED NOT NULL,
  target_type_id INT UNSIGNED NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS target_types;
CREATE TABLE target_types (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);


DROP TABLE IF EXISTS posts;
CREATE TABLE posts (
   id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
   user_id INT UNSIGNED NOT NULL,
   post TEXT,
   created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);


INSERT INTO target_types (name) VALUES 
  ('messages'),
  ('users'),
  ('media'),
  ('posts');

INSERT INTO likes 
  SELECT 
    id, 
    FLOOR(1 + (RAND() * 100)), 
    FLOOR(1 + (RAND() * 100)),
    FLOOR(1 + (RAND() * 4)),
    CURRENT_TIMESTAMP 
  FROM messages;
 
 
TRUNCATE posts;
INSERT INTO posts
  SELECT 
    id, 
    FLOOR(1 + (RAND() * 100)),
    ELT(FLOOR(1 + (RAND() * 10)), 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.', 
        'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.', 
        'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.', 
        'On the other hand, we denounce with righteous indignation and dislike men who are so beguiled and demoralized by the charms of pleasure of the moment, so blinded by desire, that they cannot foresee the pain and trouble that are bound to ensue; and equal blame belongs to those who fail in their duty through weakness of will, which is the same as saying through shrinking from toil and pain. These cases are perfectly simple and easy to distinguish.',
        'In a free hour, when our power of choice is untrammelled and when nothing prevents our being able to do what we like best, every pleasure is to be welcomed and every pain avoided. But in certain circumstances and owing to the claims of duty or the obligations of business it will frequently occur that pleasures have to be repudiated and annoyances accepted.'
        'The wise man therefore always holds in these matters to this principle of selection: he rejects pleasures to secure other greater pleasures, or else he endures pains to avoid worse pains.',
        'At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga.',
        'Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est, omnis dolor repellendus.',
        'Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae.',
        'Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat.',
        'Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem.',
        'Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt.'),
    CURRENT_TIMESTAMP 
  FROM messages;

SELECT * FROM likes LIMIT 10;
SELECT * FROM target_types LIMIT 10;
SELECT * FROM posts;

DESC posts;

ALTER TABLE posts
  ADD CONSTRAINT posts_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE;

DESC profiles;

ALTER TABLE profiles
  ADD CONSTRAINT profiles_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT profiles_photo_id_fk
    FOREIGN KEY (photo_id) REFERENCES media(id)
      ON DELETE SET NULL;
 
DESC messages;

ALTER TABLE messages
  ADD CONSTRAINT messages_from_user_id_fk 
    FOREIGN KEY (from_user_id) REFERENCES users(id),
  ADD CONSTRAINT messages_to_user_id_fk 
    FOREIGN KEY (to_user_id) REFERENCES users(id);

ALTER TABLE messages
  ADD CONSTRAINT messages_communitie_id_fk
    FOREIGN KEY (communitie_id) REFERENCES communities(id)
      ON DELETE CASCADE;
     
UPDATE messages SET communitie_id = FLOOR(1 + RAND()*20);

SELECT * FROM messages;
SELECT * FROM communities;

DESC communities;

DESC communities_users;

ALTER TABLE communities_users 
  ADD CONSTRAINT communities_users_community_id_fk 
    FOREIGN KEY (community_id) REFERENCES communities(id),
  ADD CONSTRAINT communities_users_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id);

SELECT * FROM communities_users;

DESC media;

ALTER TABLE media
  ADD CONSTRAINT media_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id),
  ADD CONSTRAINT media_media_type_id_fk 
    FOREIGN KEY (media_type_id) REFERENCES media_types(id);
   
SELECT * FROM media;

SELECT * FROM friendship;

DESC friendship;

ALTER TABLE friendship 
  ADD CONSTRAINT friendship_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id),
  ADD CONSTRAINT friendship_friend_id_fk 
    FOREIGN KEY (friend_id) REFERENCES users(id),
  ADD CONSTRAINT friendship_statuses_status_id_fk 
    FOREIGN KEY (status_id) REFERENCES friendship_statuses(id);

DESC likes;

ALTER TABLE likes 
  ADD CONSTRAINT likes_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id),
  ADD CONSTRAINT likes_target_type_id_fk 
    FOREIGN KEY (target_type_id) REFERENCES target_types(id);
   
SELECT * FROM likes;


-- 3. Подсчитать общее количество лайков десяти самых молодых пользователей.


SELECT * FROM profiles;

SELECT user_id, birthday FROM profiles WHERE DATE_FORMAT(birthday, '%Y') >= 2012;

UPDATE profiles SET 
    birthday = birthday - INTERVAL 10 YEAR 
    WHERE DATE_FORMAT(birthday, '%Y') >= 2012;

SELECT user_id FROM profiles ORDER BY birthday DESC LIMIT 10; # user_id 10 ñàìûõ ìîëîäûõ ïîëüçîâàòåëåé

SELECT * FROM likes LIMIT 20;

SELECT * FROM likes
	WHERE user_id IN (
		SELECT * FROM (
			SELECT user_id FROM profiles ORDER by birthday DESC LIMIT 10) as user_id); # Ëàéêè ïðîñòàâëåííûå ýòèìè ïîëüçîâàòåëÿìè

SELECT COUNT(*) as sum_likes FROM likes WHERE id IN (
	SELECT id FROM likes
	WHERE user_id IN (
		SELECT * FROM (SELECT user_id FROM profiles ORDER BY birthday DESC LIMIT 10) as user_id));

-- 4. Определить кто больше поставил лайков (всего) - мужчины или женщины?

SELECT * FROM profiles LIMIT 20;

SELECT user_id, gender FROM profiles WHERE gender = 'M'; #  user_id ìóæ÷èí

SELECT COUNT(*) as sum_likes_male FROM likes WHERE id IN (
	SELECT id FROM likes
	WHERE user_id IN (
		SELECT * FROM (SELECT user_id FROM profiles WHERE gender = 'M') as user_id)); # Êîëè÷åñòâî ëàéêîâ, ñäåëàííûå ìóæ÷èíàìè
	
SELECT COUNT(*) as sum_likes_female FROM likes WHERE id IN (
	SELECT id FROM likes
	WHERE user_id IN (
		SELECT * FROM (SELECT user_id FROM profiles WHERE gender = 'F') as user_id)); # Êîëè÷åñòâî ëàéêîâ, ñäåëàííûå æåíùèíàìè

SELECT (CASE 
 WHEN (SELECT COUNT(*) as sum_likes_female FROM likes WHERE id IN (
	SELECT id FROM likes
	WHERE user_id IN (SELECT * FROM (SELECT user_id FROM profiles WHERE gender = 'F') as user_id))) >
	   (SELECT COUNT(*) as sum_likes_male FROM likes WHERE id IN (
	SELECT id FROM likes
	WHERE user_id IN (
		SELECT * FROM (SELECT user_id FROM profiles WHERE gender = 'M') as user_id))) THEN 'Æåíùèíû ïîñòàâèëè áîëüøå ëàéêîâ'
  WHEN (SELECT COUNT(*) as sum_likes_female FROM likes WHERE id IN (
	SELECT id FROM likes
	WHERE user_id IN (SELECT * FROM (SELECT user_id FROM profiles WHERE gender = 'F') as user_id))) <
	   (SELECT COUNT(*) as sum_likes_male FROM likes WHERE id IN (
	SELECT id FROM likes
	WHERE user_id IN (
		SELECT * FROM (SELECT user_id FROM profiles WHERE gender = 'M') as user_id))) THEN 'Ìóæ÷èíû ïîñòàâèëè áîëüøå ëàéêîâ'
  ELSE 'Îäèíàêîâîå êîëè÷åñòâî ëàéêîâ ó æåíùèí è ìóæ÷èí'
  END) AS comparison;


-- 5. Найти 10 пользователей, которые проявляют наименьшую активность в 
-- использовании социальной сети(критерии активности необходимо определить самостоятельно).
-- Критерий: 1) сумма количества media файлов,
	   (SELECT id, 0 as activite FROM users WHERE id NOT IN (SELECT user_id FROM media GROUP by user_id))
        UNION
       (SELECT user_id as id, COUNT(*) as activite FROM media GROUP BY user_id);
--           2) количества posts, 
       (SELECT id, 0 as activite FROM users WHERE id NOT IN (SELECT user_id FROM posts GROUP by user_id))
       UNION 
       (SELECT user_id as id, COUNT(*) as activite FROM posts GROUP BY user_id);
--           3) количества messages, 
       (SELECT id, 0 as activite FROM users WHERE id NOT IN (SELECT from_user_id FROM messages GROUP by from_user_id))
        UNION
       (SELECT from_user_id as id, COUNT(*) as activite FROM messages GROUP BY from_user_id);
--           4) количества likes (чем меньше сумма, тем пользователь менее активен).
       (SELECT id, 0 as activite FROM users WHERE id NOT IN (SELECT user_id FROM likes GROUP by user_id))
        UNION
       (SELECT user_id as id, COUNT(*) as activite FROM likes GROUP BY user_id);


SELECT id, SUM(activite) as total_activite FROM (
	SELECT * FROM (
	   (SELECT id, 0 as activite FROM users WHERE id NOT IN (SELECT user_id FROM media GROUP by user_id))
        UNION
       (SELECT user_id as id, COUNT(*) as activite FROM media GROUP BY user_id)
        ) as tmp_med
    UNION ALL
    SELECT * FROM (
        (SELECT id, 0 as activite FROM users WHERE id NOT IN (SELECT user_id FROM posts GROUP by user_id))
        UNION 
        (SELECT user_id as id, COUNT(*) as activite FROM posts GROUP BY user_id)
         ) as tmp_pos
    UNION ALL
    SELECT * FROM (
	    (SELECT id, 0 as activite FROM users WHERE id NOT IN (SELECT from_user_id FROM messages GROUP by from_user_id))
         UNION
        (SELECT from_user_id as id, COUNT(*) as activite FROM messages GROUP BY from_user_id)
         ) as tmp_mes
    UNION ALL 
    SELECT * FROM (
        (SELECT id, 0 as activite FROM users WHERE id NOT IN (SELECT user_id FROM likes GROUP by user_id))
         UNION
        (SELECT user_id as id, COUNT(*) as activite FROM likes GROUP BY user_id)
        ) as tmp_lik
  ) as tmp_table
 GROUP BY id  ORDER BY total_activite LIMIT 10;
        


