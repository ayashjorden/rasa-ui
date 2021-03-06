/*Alters after release 2.1 version*/
CREATE SEQUENCE public.messages_messages_id_seq
INCREMENT 1
START 1
MINVALUE 1
MAXVALUE 9223372036854775807
CACHE 1;

CREATE TABLE public.messages
(
  messages_id integer NOT NULL DEFAULT nextval('messages_messages_id_seq'::regclass),
  "timestamp" timestamp without time zone DEFAULT timezone('utc'::text, now()),
  agent_id integer,
  user_id character varying COLLATE pg_catalog."default",
  user_name character varying COLLATE pg_catalog."default",
  message_text character varying COLLATE pg_catalog."default",
  message_rich jsonb,
  user_message_ind boolean,
  CONSTRAINT messages_id_pkey PRIMARY KEY (messages_id)
)
WITH (
  OIDS = FALSE
)
TABLESPACE pg_default;

DROP VIEW public.intents_most_used;
DROP VIEW public.active_user_count_12_months;
DROP VIEW public.active_user_count_30_days;

ALTER TABLE public.nlu_parse_log ADD COLUMN messages_id integer;
ALTER TABLE public.nlu_parse_log ADD CONSTRAINT messages_id_pk FOREIGN KEY (messages_id) REFERENCES public.messages (messages_id) MATCH FULL;
ALTER TABLE public.nlu_parse_log DROP COLUMN agent_id RESTRICT;

ALTER TABLE public.nlu_parse_log DROP COLUMN request_text RESTRICT;
ALTER TABLE public.nlu_parse_log DROP COLUMN response_text RESTRICT;
ALTER TABLE public.nlu_parse_log DROP COLUMN response_rich_data RESTRICT;
ALTER TABLE public.nlu_parse_log DROP COLUMN user_id RESTRICT;
ALTER TABLE public.nlu_parse_log DROP COLUMN user_name RESTRICT;

ALTER TABLE public.core_parse_log ADD COLUMN messages_id integer;
ALTER TABLE public.core_parse_log ADD CONSTRAINT messages_id_pk FOREIGN KEY (messages_id) REFERENCES public.messages (messages_id) MATCH FULL;
ALTER TABLE public.core_parse_log DROP COLUMN agent_id RESTRICT;
ALTER TABLE public.core_parse_log DROP COLUMN request_text RESTRICT;
ALTER TABLE public.core_parse_log DROP COLUMN response_text RESTRICT;
ALTER TABLE public.core_parse_log DROP COLUMN response_rich_data RESTRICT;
ALTER TABLE public.core_parse_log DROP COLUMN user_id RESTRICT;
ALTER TABLE public.core_parse_log DROP COLUMN user_name RESTRICT;
ALTER TABLE public.core_parse_log DROP COLUMN tracker_data RESTRICT;
ALTER TABLE public.core_parse_log ADD COLUMN slots_data jsonb;
ALTER TABLE public.core_parse_log DROP COLUMN action_data;
ALTER TABLE public.core_parse_log ADD COLUMN action_name character varying COLLATE pg_catalog."default";

CREATE OR REPLACE VIEW public.intents_most_used AS
select intent_name, agents.agent_id, agents.agent_name, grouped_intents.grp_intent_count from intents
left outer join (select count(*) as grp_intent_count, nlu_parse_log.intent_name as grp_intent,messages.agent_id as grp_agent_id from nlu_parse_log, messages
where nlu_parse_log.messages_id=messages.messages_id group by nlu_parse_log.intent_name,grp_agent_id) as grouped_intents
on intent_name = grouped_intents.grp_intent, agents where intents.agent_id=agents.agent_id  order by agents.agent_id;

CREATE OR REPLACE VIEW public.active_user_count_12_months AS
select count(distinct(messages.user_id)) as count_users,
(to_char(nlu_parse_log."timestamp", 'MM/YYYY'::text)) as month_year from nlu_parse_log, messages where nlu_parse_log.messages_id=messages.messages_id
GROUP BY (to_char(nlu_parse_log."timestamp", 'MM/YYYY'::text)) ORDER BY (to_char(nlu_parse_log."timestamp", 'MM/YYYY'::text)) asc LIMIT 12;

CREATE OR REPLACE VIEW public.active_user_count_30_days AS
SELECT count(distinct(messages.user_id)) as user_count,
(to_char(nlu_parse_log."timestamp", 'MM/DD'::text)) as month_date from nlu_parse_log, messages where nlu_parse_log.messages_id=messages.messages_id
GROUP BY (to_char(nlu_parse_log."timestamp", 'MM/DD'::text))
ORDER BY (to_char(nlu_parse_log."timestamp", 'MM/DD'::text)) asc
LIMIT 30;

/*Alters after release 1.0 version*/

CREATE SEQUENCE public.actions_action_id_seq
INCREMENT 1
START 1
MINVALUE 1
MAXVALUE 9223372036854775807
CACHE 1;

CREATE SEQUENCE public.core_parse_log_core_parse_log_id_seq
INCREMENT 1
START 1
MINVALUE 1
MAXVALUE 9223372036854775807
CACHE 1;

CREATE TABLE public.actions
(
  action_name character varying COLLATE pg_catalog."default" NOT NULL,
  agent_id integer,
  action_id integer NOT NULL DEFAULT nextval('actions_action_id_seq'::regclass)
)
WITH (
  OIDS = FALSE
)
TABLESPACE pg_default;

CREATE TABLE public.core_parse_log
(
  core_parse_log_id integer NOT NULL DEFAULT nextval('core_parse_log_core_parse_log_id_seq'::regclass),
  "timestamp" timestamp without time zone DEFAULT timezone('utc'::text, now()),
  agent_id integer,
  request_text character varying COLLATE pg_catalog."default",
  action_data jsonb[],
  tracker_data jsonb[],
  response_text jsonb[],
  response_rich_data jsonb[],
  user_id character varying COLLATE pg_catalog."default",
  user_name character varying COLLATE pg_catalog."default",
  user_response_time_ms integer,
  core_response_time_ms integer,
  CONSTRAINT core_parse_log_id PRIMARY KEY (core_parse_log_id)
)
WITH (
  OIDS = FALSE
)
TABLESPACE pg_default;


ALTER TABLE public.responses ADD COLUMN action_id integer;
ALTER TABLE public.responses ADD COLUMN buttons_info jsonb;
ALTER TABLE public.responses ADD COLUMN response_image_url character varying COLLATE pg_catalog."default";
ALTER TABLE public.responses ALTER COLUMN intent_id DROP NOT NULL;

ALTER TABLE public.agents ADD COLUMN story_details text COLLATE pg_catalog."default";
ALTER TABLE public.agents ADD COLUMN rasa_core_enabled boolean DEFAULT FALSE;

ALTER TABLE public.entities ADD COLUMN slot_data_type character varying COLLATE pg_catalog."default" NOT NULL default 'NOT_USED';
ALTER TABLE public.entities ADD COLUMN agent_id integer;

/*Alters to release 1.0 version*/
CREATE SEQUENCE public.parse_log_parse_log_id_seq
INCREMENT 1
START 1
MINVALUE 1
MAXVALUE 9223372036854775807
CACHE 1;

ALTER TABLE public.agents ADD COLUMN endpoint_enabled boolean DEFAULT FALSE;
ALTER TABLE public.agents ADD COLUMN endpoint_url character varying COLLATE pg_catalog."default";
ALTER TABLE public.agents ADD COLUMN basic_auth_username character varying COLLATE pg_catalog."default";
ALTER TABLE public.agents ADD COLUMN basic_auth_password character varying COLLATE pg_catalog."default";
ALTER TABLE public.agents ADD COLUMN client_secret_key text NOT NULL default md5(random()::text);

ALTER TABLE public.intents  ADD COLUMN endpoint_enabled boolean;

CREATE TABLE public.nlu_parse_log
(
  parse_log_id integer NOT NULL DEFAULT nextval('parse_log_parse_log_id_seq'::regclass),
  "timestamp" timestamp without time zone DEFAULT timezone('utc'::text, now()),
  agent_id integer,
  request_text character varying COLLATE pg_catalog."default",
  intent_name character varying COLLATE pg_catalog."default",
  entity_data jsonb,
  response_text character varying COLLATE pg_catalog."default",
  response_rich_data jsonb,
  intent_confidence_pct integer,
  user_id character varying COLLATE pg_catalog."default",
  user_name character varying COLLATE pg_catalog."default",
  user_response_time_ms integer,
  nlu_response_time_ms integer,
  CONSTRAINT parse_log_id_pkey PRIMARY KEY (parse_log_id)
)
WITH (
  OIDS = FALSE
)
TABLESPACE pg_default;

CREATE OR REPLACE VIEW public.intents_most_used AS
select intent_name, agents.agent_id, agents.agent_name, grouped_intents.grp_intent_count from intents
left outer join (select count(*) as grp_intent_count, intent_name as grp_intent,agent_id as grp_agent_id from nlu_parse_log
group by (intent_name,agent_id)) as grouped_intents
on intent_name = grouped_intents.grp_intent, agents where intents.agent_id=agents.agent_id  order by agents.agent_id;

CREATE OR REPLACE VIEW public.avg_nlu_response_times_30_days AS
select round(avg(nlu_response_time_ms)::integer,0),
(to_char(nlu_parse_log."timestamp", 'MM/DD'::text)) as month_date from nlu_parse_log
GROUP BY (to_char(nlu_parse_log."timestamp", 'MM/DD'::text))
ORDER BY (to_char(nlu_parse_log."timestamp", 'MM/DD'::text)) desc
LIMIT 30;

CREATE OR REPLACE VIEW public.avg_user_response_times_30_days AS
select round(avg(user_response_time_ms)::integer,0),
(to_char(nlu_parse_log."timestamp", 'MM/DD'::text)) as month_date from nlu_parse_log
GROUP BY (to_char(nlu_parse_log."timestamp", 'MM/DD'::text))
ORDER BY (to_char(nlu_parse_log."timestamp", 'MM/DD'::text)) desc
LIMIT 30;

CREATE OR REPLACE VIEW public.active_user_count_12_months AS
select count(distinct(user_id)) as count_users,
(to_char(nlu_parse_log."timestamp", 'MM/YYYY'::text)) as month_year from nlu_parse_log
GROUP BY (to_char(nlu_parse_log."timestamp", 'MM/YYYY'::text))
ORDER BY (to_char(nlu_parse_log."timestamp", 'MM/YYYY'::text)) desc
LIMIT 12;

CREATE OR REPLACE VIEW public.active_user_count_30_days AS
SELECT count(distinct(user_id)) as user_count,
(to_char(nlu_parse_log."timestamp", 'MM/DD'::text)) as month_date from nlu_parse_log
GROUP BY (to_char(nlu_parse_log."timestamp", 'MM/DD'::text))
ORDER BY (to_char(nlu_parse_log."timestamp", 'MM/DD'::text)) desc
LIMIT 30;

ALTER TABLE public.entities DROP CONSTRAINT agent_pk;
ALTER TABLE public.entities DROP agent_id;

CREATE SEQUENCE public.regex_id_seq
INCREMENT 1
START 1
MINVALUE 1
MAXVALUE 9223372036854775807
CACHE 1;

CREATE TABLE public.regex
(
  regex_id integer NOT NULL DEFAULT nextval('regex_id_seq'::regclass),
  regex_name character varying COLLATE pg_catalog."default",
  regex_pattern character varying COLLATE pg_catalog."default",
  CONSTRAINT regex_id_pk PRIMARY KEY (regex_id)
)
WITH (
  OIDS = FALSE
)
TABLESPACE pg_default;
