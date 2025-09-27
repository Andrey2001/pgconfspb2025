-----------------------------------------------------------------
--
-- Эксперименты с перепланированием (AQE)
--
-----------------------------------------------------------------

-- 1 AQE time_trigger
-- Этот запрос - самый первый по алфавиту остросюжетный фильм компании Lionsgate.
\i ~/31c.sql

--                                                                                                       QUERY PLAN                                                                                       -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--  Aggregate  (cost=9508.39..9508.40 rows=1 width=128) (actual time=58647.640..58647.764 rows=1 loops=1)
--    ->  Nested Loop  (cost=1012.76..9508.38 rows=1 width=81) (actual time=495.534..58641.981 rows=2825 loops=1)
--          Join Filter: (mi.movie_id = t.id)
--          ->  Nested Loop  (cost=1012.33..9507.22 rows=1 width=84) (actual time=495.479..58582.795 rows=2825 loops=1)
--                ->  Nested Loop  (cost=1011.90..9505.87 rows=1 width=73) (actual time=495.138..58485.974 rows=2825 loops=1)
--                      ->  Nested Loop  (cost=1011.48..9504.77 rows=1 width=77) (actual time=39.198..51693.277 rows=589677 loops=1)
--                            Join Filter: (mc.movie_id = mi.movie_id)
--                            ->  Nested Loop  (cost=1011.05..9502.43 rows=1 width=69) (actual time=39.139..49882.720 rows=42900 loops=1)
--                                  Join Filter: (ci.movie_id = mi.movie_id)
--                                  ->  Gather  (cost=1010.61..9478.06 rows=1 width=61) (actual time=24.465..2620.721 rows=63386 loops=1)
--                                        Workers Planned: 2
--                                        Workers Launched: 2
--                                        ->  Nested Loop  (cost=10.61..8477.96 rows=1 width=61) (actual time=13.309..3922.218 rows=21129 loops=3)
--                                              ->  Nested Loop  (cost=10.46..8477.45 rows=3 width=65) (actual time=13.279..3786.771 rows=22577 loops=3)
--                                                    Join Filter: (mi.movie_id = mi_idx.movie_id)
--                                                    ->  Hash Join  (cost=10.03..8467.21 rows=3 width=14) (actual time=13.047..1243.569 rows=21234 loops=3)
--                                                          Hash Cond: (mi_idx.info_type_id = it2.id)
--                                                          ->  Nested Loop  (cost=7.61..8463.94 rows=308 width=18) (actual time=12.054..1207.129 rows=63896 loops=3)
--                                                                ->  Nested Loop  (cost=7.18..8349.84 rows=98 width=4) (actual time=11.755..581.439 rows=25571 loops=3)
--                                                                      ->  Parallel Index Scan using keyword_pkey on keyword k  (cost=0.42..5134.60 rows=3 width=4) (actual time=2.390..123.886 rows=2 loops=3)
--                                                                            Filter: (keyword = ANY ('{murder,violence,blood,gore,death,female-nudity,hospital}'::text[]))
--                                                                            Rows Removed by Filter: 44721
--                                                                      ->  Bitmap Heap Scan on movie_keyword mk  (cost=6.76..1068.74 rows=300 width=8) (actual time=6.938..191.697 rows=10959 loops=7)
--                                                                            Recheck Cond: (k.id = keyword_id)
--                                                                            Heap Blocks: exact=12389
--                                                                            ->  Bitmap Index Scan on keyword_id_movie_keyword  (cost=0.00..6.68 rows=300 width=0) (actual time=4.373..4.373 rows=10959 loops=7)
--                                                                                  Index Cond: (keyword_id = k.id)
--                                                                ->  Index Scan using movie_id_movie_info_idx on movie_info_idx mi_idx  (cost=0.43..1.13 rows=3 width=14) (actual time=0.021..0.023 rows=2 loops=76714)
--                                                                      Index Cond: (movie_id = mk.movie_id)
--                                                          ->  Hash  (cost=2.41..2.41 rows=1 width=4) (actual time=0.149..0.150 rows=1 loops=3)
--                                                                Buckets: 1024  Batches: 1  Memory Usage: 9kB
--                                                                ->  Seq Scan on info_type it2  (cost=0.00..2.41 rows=1 width=4) (actual time=0.132..0.135 rows=1 loops=3)
--                                                                      Filter: ((info)::text = 'votes'::text)
--                                                                      Rows Removed by Filter: 112
--                                                    ->  Index Scan using movie_id_movie_info on movie_info mi  (cost=0.43..3.40 rows=1 width=51) (actual time=0.084..0.119 rows=1 loops=63701)
--                                                          Index Cond: (movie_id = mk.movie_id)
--                                                          Filter: (info = ANY ('{Horror,Action,Sci-Fi,Thriller,Crime,War}'::text[]))
--                                                          Rows Removed by Filter: 58
--                                              ->  Index Scan using info_type_pkey on info_type it1  (cost=0.14..0.16 rows=1 width=4) (actual time=0.005..0.005 rows=1 loops=67732)
--                                                    Index Cond: (id = mi.info_type_id)
--                                                    Filter: ((info)::text = 'genres'::text)
--                                                    Rows Removed by Filter: 0
--                                  ->  Index Scan using movie_id_cast_info on cast_info ci  (cost=0.44..24.36 rows=1 width=8) (actual time=0.608..0.744 rows=1 loops=63386)
--                                        Index Cond: (movie_id = mk.movie_id)
--                                        Filter: (note = ANY ('{(writer),"(head writer)","(written by)",(story),"(story editor)"}'::text[]))
--                                        Rows Removed by Filter: 63
--                            ->  Index Scan using movie_id_movie_companies on movie_companies mc  (cost=0.43..2.28 rows=5 width=8) (actual time=0.019..0.034 rows=14 loops=42900)
--                                  Index Cond: (movie_id = mk.movie_id)
--                      ->  Index Scan using company_name_pkey on company_name cn  (cost=0.42..1.04 rows=1 width=4) (actual time=0.011..0.011 rows=0 loops=589677)
--                            Index Cond: (id = mc.company_id)
--                            Filter: (name ~~ 'Lionsgate%'::text)
--                            Rows Removed by Filter: 1
--                ->  Index Scan using name_pkey on name n  (cost=0.43..1.35 rows=1 width=19) (actual time=0.033..0.033 rows=1 loops=2825)
--                      Index Cond: (id = ci.person_id)
--          ->  Index Scan using title_pkey on title t  (cost=0.43..1.15 rows=1 width=21) (actual time=0.019..0.019 rows=1 loops=2825)
--                Index Cond: (id = mk.movie_id)
--  Planning Time: 148.072 ms
--  Execution Time: 58648.535 ms
-- (58 rows)


set aqe_enable =on;
Set aqe_sql_execution_time_trigger = 1000;

\i ~/31c.sql
-- попробуйте другие значения aqe_sql_execution_time_trigger. Что у вас получается?


-----------------------------------------------------------------
--
-- 2 AQE replan_signal()
-- Вызовем запрос на перепланирование из другого бекенда
--
----------------------------------------------------------------

-- первый бэкенд: уберем триггер по времени, но оставим ВКЛЮЧЕННЫМ AQE 
reset aqe_sql_execution_time_trigger;
-- запускаем запрос
\i ~/16b.sql

--                                                                                       QUERY PLAN
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--  Aggregate  (cost=5178.97..5178.98 rows=1 width=64) (actual time=80381.230..80381.235 rows=1 loops=1)
--    ->  Nested Loop  (cost=9.33..5163.78 rows=3038 width=33) (actual time=8.936..78706.181 rows=3710592 loops=1)
--          Join Filter: (an.person_id = n.id)
--          ->  Nested Loop  (cost=8.91..4543.40 rows=1275 width=25) (actual time=8.907..46513.907 rows=2832555 loops=1)
--                ->  Nested Loop  (cost=8.48..3971.21 rows=1275 width=21) (actual time=8.877..18180.563 rows=2832555 loops=1)
--                      Join Filter: (ci.movie_id = t.id)
--                      ->  Nested Loop  (cost=8.04..3854.82 rows=63 width=29) (actual time=8.289..4050.385 rows=68316 loops=1)
--                            ->  Nested Loop  (cost=7.62..3775.44 rows=178 width=33) (actual time=8.199..1700.920 rows=148552 loops=1)
--                                  Join Filter: (mc.movie_id = t.id)
--                                  ->  Nested Loop  (cost=7.19..3754.96 rows=34 width=25) (actual time=8.114..917.325 rows=41840 loops=1)
--                                        ->  Nested Loop  (cost=6.76..3738.45 rows=34 width=4) (actual time=8.077..291.132 rows=41840 loops=1)
--                                              ->  Seq Scan on keyword k  (cost=0.00..2628.12 rows=1 width=4) (actual time=1.234..46.571 rows=1 loops=1)
--                                                    Filter: (keyword = 'character-name-in-title'::text)
--                                                    Rows Removed by Filter: 134169
--                                              ->  Bitmap Heap Scan on movie_keyword mk  (cost=6.76..1107.32 rows=300 width=8) (actual time=6.839..228.549 rows=41840 loops=1)
--                                                    Recheck Cond: (k.id = keyword_id)
--                                                    Heap Blocks: exact=11541
--                                                    ->  Bitmap Index Scan on keyword_id_movie_keyword  (cost=0.00..6.68 rows=300 width=0) (actual time=4.347..4.347 rows=41840 loops=1)
--                                                          Index Cond: (keyword_id = k.id)
--                                        ->  Index Scan using title_pkey on title t  (cost=0.43..0.49 rows=1 width=21) (actual time=0.014..0.014 rows=1 loops=41840)
--                                              Index Cond: (id = mk.movie_id)
--                                  ->  Index Scan using movie_id_movie_companies on movie_companies mc  (cost=0.43..0.54 rows=5 width=8) (actual time=0.012..0.016 rows=4 loops=41840)
--                                        Index Cond: (movie_id = mk.movie_id)
--                            ->  Index Scan using company_name_pkey on company_name cn  (cost=0.42..0.45 rows=1 width=4) (actual time=0.015..0.015 rows=0 loops=148552)
--                                  Index Cond: (id = mc.company_id)
--                                  Filter: ((country_code)::text = '[us]'::text)
--                                  Rows Removed by Filter: 1
--                      ->  Index Scan using movie_id_cast_info on cast_info ci  (cost=0.44..1.37 rows=38 width=8) (actual time=0.017..0.189 rows=41 loops=68316)
--                            Index Cond: (movie_id = mk.movie_id)
--                ->  Index Only Scan using name_pkey on name n  (cost=0.43..0.45 rows=1 width=4) (actual time=0.009..0.009 rows=1 loops=2832555)
--                      Index Cond: (id = ci.person_id)
--                      Heap Fetches: 0
--          ->  Index Scan using person_id_aka_name on aka_name an  (cost=0.42..0.46 rows=2 width=20) (actual time=0.009..0.010 rows=1 loops=2832555)
--                Index Cond: (person_id = ci.person_id)
--  Planning Time: 17.935 ms
--  Execution Time: 80381.781 ms
-- (36 rows)

-- второй бэкенд: подключаемся к машине с другого терминала
-- $ ssh {USER}@{PID}
-- ищем нужный ID процессора, где у нас запущен запрос
-- $ ps -ax | grep postgres | grep 'EXPLAIN'
-- присоединяемся ко второму бекенду
-- $ psql -p {PORT} -d postgres
-- вызываем функцию которая запустит вручную перепланирование
select replan_signal({PID}); -- пока выполняется запрос
-- запустите так много раз с периодичность в 2-5 секунд или как вам удобнее


------------------------------------------------------------------
--
-- Поиграемся с автосигналом
--
------------------------------------------------------------------

--автосигнал
--aqe_auto_signal.sh --times {TIMES} --port {PORT} --pid {PID} --timeout {TIMEOUT}
--Пример:
./aqe_auto_signal.sh --times 5 --port 5436 --pid 107198 --timeout 1.5




------------------------------------------------------------------
--
-- Эксперименты с расширением, что сохраняет 
-- выгодный план запроса (pgpro_multiplan)
--
------------------------------------------------------------------

------------------------------------------------------------------
--
-- Поймает оптимальный план запроса найденного AQE и
-- сохраним его для дальнейшего использования
--
------------------------------------------------------------------

-- созддим расширение pgpro_multiplan
-- заресетим все значения для него для честного эксперимента
create extension pgpro_multiplan;
SELECT pgpro_multiplan_reset();

-- доп команды проверки, что всё установлено
\dconfig *aqe*
\dx
\dv
\dconfig pgpro_multi*
SHOW shared_preload_libraries;

-- Настроим гук auto_capturing и установим режим 'baseline'

SET pgpro_multiplan.mode = 'baseline';
SET pgpro_multiplan.auto_capturing = on;
SET aqe_enable = on; -- если ещё не включен

-- выполнить запрос несколько раз с разными значениями aqe_sql_execution_time_trigger:
-- возьмём значения по несколько секунд
set aqe_sql_execution_time_trigger = 30000;
\i ~/30с.sql;
set aqe_sql_execution_time_trigger = 10000;
\i ~/30с.sql;
set aqe_sql_execution_time_trigger = 5000;
\i ~/30с.sql;

-- захват закончили выключаем
SET pgpro_multiplan.auto_capturing = off; -- ! выключаем обязательно иначе не сработают разрешенные планы

-- видим несколько захваченных планов
SELECT left(query_string, 100), dbid, sql_hash, plan_hash, cost FROM pgpro_multiplan_captured_queries;
-- какой из них лучше по вашему мнению?
--                                     left                                     | dbid |      sql_hash       |      plan_hash       |     cost
-- -----------------------------------------------------------------------------+------+---------------------+----------------------+--------------------
--  SELECT MIN(mi.info) AS movie_budget,                                       +|    5 | 6251091346033266000 |   -52356214523280641 | 17985.755987622757
--         MIN(mi_idx.info) AS movie_votes,                                    +|      |                     |                      |
--         MIN(n.name) AS w                                                     |      |                     |                      |
--  SELECT s.name AS "Parameter", pg_catalog.current_setting(s.name) AS "Value"+|    5 | 3248707178069435472 | -6939563903564495251 | 15.0225
--  FROM pg_catalog.pg_setti                                                    |      |                     |                      |
--  SELECT MIN(mi.info) AS movie_budget,                                       +|    5 | 6251091346033266000 | -3233104676300122008 | 4472.034143105042
--         MIN(mi_idx.info) AS movie_votes,                                    +|      |                     |                      |
--         MIN(n.name) AS w                                                     |      |                     |                      |
-- (3 rows)

-- в хранилище разрешенных и замороженных пока пусто - 
-- значит оптимизатор пока ничего не будет использовать еще
-- значит мы пока планы "не разрешили" для использования
SELECT left(query_string, 100), dbid, sql_hash, plan_hash, cost FROM pgpro_multiplan_storage;

-- создаём переменные с числами или вручную копируем числа в captured_approve
-- {NUMB} - план хеш понравившегося плана
select dbid, sql_hash, plan_hash from pgpro_multiplan_captured_queries where plan_hash = {NUMB} \gset

-- одобряем понравившийся план
SELECT pgpro_multiplan_captured_approve(:dbid, :sql_hash, :plan_hash);

-- проверяем что добавился в разрешенные
SELECT left(query_string, 100), dbid, sql_hash, plan_hash, cost FROM pgpro_multiplan_storage;
--                   left                   | dbid |      sql_hash       |     plan_hash      |        cost
-- -----------------------------------------+------+---------------------+--------------------+--------------------
--  SELECT MIN(mi.info) AS movie_budget,   +|    5 | 6251091346033266000 | -52356214523280641 | 17985.755987622757
--         MIN(mi_idx.info) AS movie_votes,+|      |                     |                    |
--         MIN(n.name) AS w                 |      |                     |                    |
-- (1 row)

SET aqe_enable = off;

-- должны увидеть кастомную ноду мультиплана с информацией
\i ~/30c.sql;


-----------------------------------------------------------------
--
-- А давайте рассмотрим, как нам можно делть это автоматически
-- auto_approve_plans!
--
-----------------------------------------------------------------

-- 4 auto_approve_plans 'baseline'
-- Настроим нужные параметры
SET pgpro_multiplan.mode = 'baseline';
SET pgpro_multiplan.aqe_mode = 'auto_approve_plans';
SET aqe_enable = on;

-- выполнить запрос с некоторым значением aqe_sql_execution_time_trigger, например 1000
\i ~/16b.sql;

-- смотрим планы в разрешенных
SELECT left(query_string, 100), dbid, sql_hash, plan_hash, cost FROM pgpro_multiplan_storage;

SET aqe_enable = off;

-- повторяем запрос, он должен быть из разрешённых
\i ~/16b.sql;


------------------------------------------------------------------
--
-- Можно собирать статистику по AQE и на основе нее попытаться 
-- предугадать, какой параметр по времени был лучше 
--
------------------------------------------------------------------

-- 5 Поставим aqe мод в сбор статистики: aqe_statistics
SET pgpro_multiplan.aqe_mode = 'statistics';
SET aqe_enable = on;

-- Создаём для удобства такое представление
create view aqe_stats_tmp as
select sql_hash, planid, left(query,100), last_updated, exec_num, min_attempts, max_attempts, 
total_attempts, reason_repeated_plan, reason_no_data, reason_max_reruns, reason_external, reruns_forced , 
reruns_time, reruns_underestimation , reruns_memory, min_planning_time, max_planning_time, 
mean_planning_time, stddev_planning_time, min_exec_time, max_exec_time, mean_exec_time, stddev_exec_time from aqe_stats;

-- выполняем разные запросы
\i ~/19b.sql;

select * from aqe_stats_tmp \gx
-- -[ RECORD 1 ]----------+---------------------------------------------
-- sql_hash               | -1905835497816146276
-- planid                 | 2410723918756208619
-- left                   | SELECT MIN(n.name) AS voicing_actress,      +
--                        |        MIN(t.title) AS jap_engl_voiced_movie+
--                        | FROM aka_name AS
-- last_updated           | 2025-09-27 16:50:21.019078+00
-- exec_num               | 1
-- min_attempts           | 4
-- max_attempts           | 4
-- total_attempts         | 4
-- reason_repeated_plan   | 0
-- reason_no_data         | 0
-- reason_max_reruns      | 0
-- reason_external        | 0
-- reruns_forced          | 0
-- reruns_time            | 0
-- reruns_underestimation | 4
-- reruns_memory          | 0
-- min_planning_time      | 140942.774109
-- max_planning_time      | 140942.774109
-- mean_planning_time     | 140942.774109
-- stddev_planning_time   | 0
-- min_exec_time          | 11429.874643
-- max_exec_time          | 11429.874643
-- mean_exec_time         | 11429.874643
-- stddev_exec_time       | 0
-- ...
-- Попробуйте выполнить запрос с другими параметрами по AQE или другие ранее рассматриваемые нами запросы.. 
-- Какую информацию о статистики вы найдете? 


------------------------------------------------------------------
--
-- Помощник оптимизатора Postgres pgpro_planner
--
-----------------------------------------------------------------
--
-- Посмотрим на примере, как он помогает преобразовать экспрешены
-- в удобный и понимаемый вид для оптимизатора
-- Рассмотрим запрос с Values - трудные для оптимизатора
--
--
-- Запрос выполняется долго из-за избыточных джойнов, формируемые
-- между основными таблицами и временными представлениями Values
--
-- Например: 
--->  Hash Semi Join  (cost=0.25..2645.26 rows=10 width=4) (actual time=0.177..45.488 rows=10 loops=1)
--     Hash Cond: (k.keyword = "*VALUES*".column1)
--     ->  Seq Scan on keyword k  (cost=0.00..2292.70 rows=134170 width=20) (actual time=0.018..24.619 rows=134170 loops=1)
--     ->  Hash  (cost=0.12..0.12 rows=10 width=32) (actual time=0.018..0.019 rows=10 loops=1)
--         ->  Values Scan on "*VALUES*"  (cost=0.00..0.12 rows=10 width=32) (actual time=0.006..0.009 rows=10 loops=1)
--
\i ~/pgpro_planner_values_any.sql

--                                                                                                QUERY PLAN
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--  Aggregate  (cost=3202.18..3202.19 rows=1 width=8) (actual time=9154.599..9154.607 rows=1 loops=1)
--    ->  Nested Loop Semi Join  (cost=2.40..3202.18 rows=1 width=0) (actual time=9154.593..9154.600 rows=0 loops=1)
--          Join Filter: (mi_idx.info = "*VALUES*_1".column1)
--          Rows Removed by Join Filter: 2610128
--          ->  Nested Loop Semi Join  (cost=2.40..3200.26 rows=15 width=6) (actual time=96.912..8721.161 rows=326266 loops=1)
--                Join Filter: (t.production_year = "*VALUES*_2".column1)
--                Rows Removed by Join Filter: 9054507
--                ->  Nested Loop  (cost=2.40..3171.31 rows=385 width=10) (actual time=82.791..7125.288 rows=1992829 loops=1)
--                      Join Filter: (mi_idx.movie_id = t.id)
--                      ->  Nested Loop  (cost=1.97..3034.33 rows=264 width=20) (actual time=82.500..2634.877 rows=652408 loops=1)
--                            ->  Nested Loop  (cost=1.53..2932.75 rows=65 width=16) (actual time=82.292..1933.193 rows=8170 loops=1)
--                                  ->  Nested Loop  (cost=1.11..2909.92 rows=48 width=12) (actual time=81.127..1859.576 rows=13935 loops=1)
--                                        Join Filter: (kt.id = t.kind_id)
--                                        Rows Removed by Join Filter: 10156
--                                        ->  Seq Scan on kind_type kt  (cost=0.00..1.09 rows=1 width=4) (actual time=0.023..0.030 rows=1 loops=1)
--                                              Filter: ((kind)::text = 'movie'::text)
--                                              Rows Removed by Filter: 6
--                                        ->  Nested Loop  (cost=1.11..2904.62 rows=337 width=16) (actual time=0.425..1855.162 rows=24091 loops=1)
--                                              ->  Nested Loop  (cost=0.68..2740.98 rows=337 width=4) (actual time=0.393..909.737 rows=24091 loops=1)
--                                                    ->  Hash Semi Join  (cost=0.25..2645.26 rows=10 width=4) (actual time=0.177..45.488 rows=10 loops=1)
--                                                          Hash Cond: (k.keyword = "*VALUES*".column1)
--                                                          ->  Seq Scan on keyword k  (cost=0.00..2292.70 rows=134170 width=20) (actual time=0.018..24.619 rows=134170 loops=1)
--                                                          ->  Hash  (cost=0.12..0.12 rows=10 width=32) (actual time=0.018..0.019 rows=10 loops=1)
--                                                                Buckets: 1024  Batches: 1  Memory Usage: 9kB
--                                                                ->  Values Scan on "*VALUES*"  (cost=0.00..0.12 rows=10 width=32) (actual time=0.006..0.009 rows=10 loops=1)
--                                                    ->  Index Scan using keyword_id_movie_keyword on movie_keyword mk  (cost=0.43..6.57 rows=300 width=8) (actual time=0.224..85.917 rows=2409 loops=10)
--                                                          Index Cond: (keyword_id = k.id)
--                                              ->  Index Scan using title_pkey on title t  (cost=0.43..0.49 rows=1 width=12) (actual time=0.039..0.039 rows=1 loops=24091)
--                                                    Index Cond: (id = mk.movie_id)
--                                  ->  Index Only Scan using movie_id_complete_cast on complete_cast cc  (cost=0.42..0.46 rows=2 width=4) (actual time=0.005..0.005 rows=1 loops=13935)
--                                        Index Cond: (movie_id = t.id)
--                                        Heap Fetches: 0
--                            ->  Index Only Scan using movie_id_cast_info on cast_info ci  (cost=0.44..1.18 rows=38 width=4) (actual time=0.054..0.077 rows=80 loops=8170)
--                                  Index Cond: (movie_id = t.id)
--                                  Heap Fetches: 0
--                      ->  Index Scan using movie_id_movie_info_idx on movie_info_idx mi_idx  (cost=0.43..0.48 rows=3 width=10) (actual time=0.005..0.006 rows=3 loops=652408)
--                            Index Cond: (movie_id = ci.movie_id)
--                ->  Materialize  (cost=0.00..0.09 rows=5 width=4) (actual time=0.000..0.000 rows=5 loops=1992829)
--                      ->  Values Scan on "*VALUES*_2"  (cost=0.00..0.06 rows=5 width=4) (actual time=0.003..0.005 rows=5 loops=1)
--          ->  Materialize  (cost=0.00..0.14 rows=8 width=32) (actual time=0.000..0.000 rows=8 loops=326266)
--                ->  Values Scan on "*VALUES*_1"  (cost=0.00..0.10 rows=8 width=32) (actual time=0.002..0.005 rows=8 loops=1)
--  Planning Time: 24.239 ms
--  Execution Time: 9155.290 ms
-- (43 rows)

--
-- Звпустим pgpro_planner - коммандой LOAD прогрузим его в сессию
-- Запустим запрос снова - какие основные отличия вы видите?
Load 'pgpro_planner';
\i ~/pgpro_planner_values_any.sql



-----------------------------------------------------------------
--
-- Другая полезная функциональность pgpro_planner - 
-- Кеширование подпланов
--
-----------------------------------------------------------------

-- Запустим сначала запрос без этой функциональности - отключим ее с помощью гука
-- Рекомендация: поставьте таймаут на 1 минуту или 2, чтобы долго не ждать
-- set statement_timeout = 60 * 60000;
set pgpro_planner.memoize_subplan = OFF;
\i ~/job_memoize.sql; 
--                                                                                 QUERY PLAN                                                                                
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--  Nested Loop  (cost=0.43..319273348.26 rows=4945240 width=17) (actual time=1.403..557055.086 rows=1788417 loops=1)
--    ->  Seq Scan on movie_info mi  (cost=0.00..316888153.47 rows=4945240 width=4) (actual time=1.332..532927.599 rows=1788417 loops=1)
--          Filter: (("substring"(info, '\d{4}'::text))::integer <= (SubPlan 1))
--          Rows Removed by Filter: 13047303
--          SubPlan 1
--            ->  Aggregate  (cost=21.32..21.33 rows=1 width=4) (actual time=0.031..0.031 rows=1 loops=14835720)
--                  ->  Index Scan using movie_id_movie_companies on movie_companies mc  (cost=0.43..21.27 rows=5 width=24) (actual time=0.011..0.016 rows=5 loops=14835720)
--                        Index Cond: (movie_id = mi.movie_id)
--    ->  Index Scan using title_pkey on title t  (cost=0.43..0.48 rows=1 width=21) (actual time=0.012..0.012 rows=1 loops=1788417)
--          Index Cond: (id = mi.movie_id)
--  Planning Time: 5.233 ms
--  Execution Time: 557517.511 ms
-- (12 rows)

-- Заметим, что большое число loops у подплана (14835720 раз).
-- Включим pgpro_planner: 
set pgpro_planner.memoize_subplan = ON;
\i ~/job_memoize.sql;

-- Что вы заметили в изменениях?



