# gitlab-search
pg設定檔位置: /var/opt/gitlab/postgresql/data/pg_hba.conf

修改設定檔(目前失敗)
vi /var/opt/gitlab/postgresql/data/pg_hba.conf
改成 trust

直接指令進入DB
(無法使用)/opt/gitlab/embedded/bin/psql -h /var/opt/gitlab/postgresql -d gitlabhq_production

方法1
apt update
apt install sudo
sudo -u gitlab-psql /opt/gitlab/embedded/bin/psql -h "/var/opt/gitlab/postgresql" -d gitlabhq_production

方法2
直接打 gitlab-psql

# GITLAB預設帳密
帳號：root
密碼：container內的 /etc/gitlab/initial_root_password
sudo cat ~/volumes/gitlab/config/initial_root_password

# 修改 /etc/gitlab/gitlab.rb(目前這種做法沒有成功過)
vi /etc/gitlab/gitlab.rb

postgresql['enable'] = true
postgresql['listen_address'] = ['0.0.0.0/0']
postgresql['port'] = 5432

gitlab-ctl restart postgresql


docker compose -f 'gitlab-search/gitlab-docker-compose.yaml' up -d --build 

# 將owner設定為自己
sudo chown <user_name> volumes/gitlab/config/gitlab.rb

SELECT * FROM projects;

docker exec -it gitlab bash -c "gitlab-ctl restart postgresql"
gitlab-psql

sudo -u gitlab-psql -t projects > gitlab-dump.sql

select * issues
select * from projects

sudo -u gitlab-psql /opt/gitlab/embedded/bin/psql \
  -h /var/opt/gitlab/postgresql -d gitlabhq_production -c "select id, name from projects;"

postgres匯出指令為:
COPY projects
TO '/tmp/projects.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');

!! 目前解法將table匯出並複製到外面：
docker exec -it gitlab bash -c "gitlab-psql -c \"COPY (select * from projects) TO '/tmp/projects.csv' WITH (FORMAT CSV, HEADER, DELIMITER ',');\""
docker cp gitlab:/tmp/projects.csv ~/

查預設密碼
sudo cat ~/volumes/gitlab/config/initial_root_password

重設密碼
docker exec -it gitlab bash -c "gitlab-rake \"gitlab:password:reset\""

SELECT * FROM public.projects p 

SELECT * FROM public.namespaces n 

SELECT 
p.id AS project_id,
*
FROM public.projects p 
LEFT JOIN public.namespaces n 
ON p.namespace_id  = n.id 