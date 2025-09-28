-----------------------------------------------------------------
--
-- Эксперименты с перепланированием (AQE)
--
-----------------------------------------------------------------

-- 1 AQE time_trigger
-- Этот запрос - самый первый по алфавиту остросюжетный фильм компании Lionsgate.
\i ~/31c.sql
-- планы запросов можно посмотреть в файле plans.sql


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
-- планы запросов можно посмотреть в файле plans.sql

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

-- необязательные команды проверки, что всё установлено
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
set aqe_sql_execution_time_trigger = 2000;
\i ~/30c.sql;
set aqe_sql_execution_time_trigger = 1000;
\i ~/30c.sql;
set aqe_sql_execution_time_trigger = 500;
\i ~/30c.sql;

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

DROP EXTENSION pgpro_multiplan CASCADE;


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
-- планы запросов можно посмотреть в файле plans.sql

-- Запустим pgpro_planner - коммандой LOAD прогрузим его в сессию
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







