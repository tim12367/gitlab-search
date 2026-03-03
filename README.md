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

SELECT * FROM public.routes

SELECT * FROM public.protected_branches pb 

# 選擇出專案資料
SELECT
p.id AS project_id, --專案ID
r.path, --完整前綴路徑
p.name, --專案名稱
p.last_activity_at ,--最後修改
p.marked_for_deletion_at , --刪除時間
p.marked_for_deletion_by_user_id , --刪除人員
p.archived , --封存或刪除
*
FROM public.projects p 
LEFT JOIN public.routes r
ON r.source_type='Project' AND p.id  = r.source_id 

# TODO
查GIT branch
將csv與branch存入

# 預定計畫
## planA: Loop Gitlab 專案 API + Loop search API
## planB: Copy projects,routes table csv + Loop search API
1. 使用gitlab的 scheduled pipeline定時啟動腳本
2. TODO要有一個任務去取更新後的檔案
## planC: Repository Mirroring to gitea (setting)
1. 修改gitea app.ini(volumes/gitea/gitea/conf/app.ini)
  ```ini
  REPO_INDEXER_ENABLED = true
  REPO_INDEXER_PATH = indexers/repos.bleve
  MAX_FILE_SIZE = 1048576
  REPO_INDEXER_INCLUDE =
  REPO_INDEXER_EXCLUDE = resources/bin/**
  ```
2. TODO 切分另一區塊做攤平分支
  改用elastic search索引
