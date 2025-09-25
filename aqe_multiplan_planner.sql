

-- 1 AQE time_trigger
-- Этот запрос самый первый по алфавиту остросюжетный фильм компании Lionsgate.
\i ~/31c.sql

set aqe_enable =on;
Set aqe_sql_execution_time_trigger = 1000;

\i ~/31c.sql

-- попробовать другие значения aqe_sql_execution_time_trigger




-- 2 AQE replan_signal()

-- первый бэкенд
reset aqe_sql_execution_time_trigger;
\i ~/16b.sql

-- второй бэкенд
-- $ ssh {USER}@{PID}
-- $ ps -ax | grep postgres | grep 'EXPLAIN'
-- $ psql -p {PORT} -d postgres
select replan_signal({PID}); -- пока выполняется запрос




create extension pgpro_multiplan;
SELECT pgpro_multiplan_reset();

-- 3 auto_capturing + captured_approve 'baseline'

SET pgpro_multiplan.mode = 'baseline';
SET pgpro_multiplan.auto_capturing = on;

SET aqe_enable = on; -- если ещё не включен

-- выполнить запрос несколько раз с разными значениями aqe_sql_execution_time_trigger:
set aqe_sql_execution_time_trigger = 30000;
\i ~/30с.sql;
set aqe_sql_execution_time_trigger = 10000;
\i ~/30с.sql;
set aqe_sql_execution_time_trigger = 5000;
\i ~/30с.sql;

-- видим несколько захваченных планов
SELECT left(query_string, 100), dbid, sql_hash, plan_hash, cost FROM pgpro_multiplan_captured_queries;

-- в хранилище разрешенных и замороженных пока пусто
SELECT left(query_string, 100), dbid, sql_hash, plan_hash, cost FROM pgpro_multiplan_storage;

SET pgpro_multiplan.auto_capturing = off; -- ! выключаем захват иначе не сработает разрешенный план

-- создаём переменные с числами или вручную копируем числа в captured_approve
select dbid, sql_hash, plan_hash from pgpro_multiplan_captured_queries where plan_hash = {NUMB} \gset

-- одобряем понравившийся план
SELECT pgpro_multiplan_captured_approve(:dbid, :sql_hash, :plan_hash);

-- проверяем что добавился в разрешенные
SELECT left(query_string, 100), dbid, sql_hash, plan_hash, cost FROM pgpro_multiplan_storage;

-- должны увидеть кастомную ноду мультиплана с информацией
\i ~/30c.sql;




-- 4 auto_approve_plans 'baseline'
SET pgpro_multiplan.mode = 'baseline';
SET pgpro_multiplan.aqe_mode = 'auto_approve_plans';

-- выполнить запрос с некоторым значением aqe_sql_execution_time_trigger, например 1000
\i ~/16b.sql;

-- смотрим планы в разрешенных
SELECT left(query_string, 100), dbid, sql_hash, plan_hash, cost FROM pgpro_multiplan_storage;

SET aqe_enable = off;

-- повторяем запрос, он должен быть из разрешённых
\i ~/16b.sql;




-- 5 aqe_statistics
SET pgpro_multiplan.aqe_mode = 'statistics'
SET aqe_enable = on;

create view aqe_stats_tmp as
select sql_hash, planid, left(query,100), last_updated, exec_num, min_attempts, max_attempts, 
total_attempts, reason_repeated_plan, reason_no_data, reason_max_reruns, reason_external, reruns_forced , 
reruns_time, reruns_underestimation , reruns_memory, min_planning_time, max_planning_time, 
mean_planning_time, stddev_planning_time, min_exec_time, max_exec_time, mean_exec_time, stddev_exec_time from aqe_stats;

-- выполняем разные запросы
\i ~/19b.sql;

select * from aqe_stats_tmp \gx




-- 6 pgpro_planner
\i ~/pgpro_planner_values_any.sql
Load 'pgpro_planner';
\i ~/pgpro_planner_values_any.sql



set pgpro_planner.memoize_subplan = OFF;
\i ~/job_memoize.sql; 

