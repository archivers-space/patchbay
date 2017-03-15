-- name: drop-all
DROP TABLE IF EXISTS urls, links, primers, crawl_urls, alerts, context, metadata, supress_alerts, snapshots;

-- name: create-primers
CREATE TABLE primers (
	id 							UUID PRIMARY KEY NOT NULL,
	created 				timestamp NOT NULL default (now() at time zone 'utc'),
	updated 				timestamp NOT NULL default (now() at time zone 'utc'),
	title 					text NOT NULL default '',
	description 		text NOT NULL default '',
	deleted 				boolean default false
);

-- name: create-crawl_urls
CREATE TABLE crawl_urls (
	url 						text PRIMARY KEY NOT NULL,
	created 				timestamp NOT NULL default (now() at time zone 'utc'),
	updated 				timestamp NOT NULL default (now() at time zone 'utc'),
	primer_id 			UUID references primers(id) not null,
	crawl 					boolean default true,
	stale_duration 	integer NOT NULL DEFAULT 43200000, -- defaults to 12 hours, column needs to be multiplied by 1000000 to become a poper duration
	last_alert_sent timestamp,
	meta 						json
);

-- name: create-urls
CREATE TABLE urls (
	url 						text PRIMARY KEY NOT NULL,
	created 				timestamp NOT NULL,
	updated 				timestamp NOT NULL,
	last_head 			timestamp,
	last_get 				timestamp,
	status 					integer NOT NULL default 0,
	content_type 		text NOT NULL default '',
	content_sniff 	text NOT NULL default '',
	content_length 	bigint NOT NULL default 0,
	title  					text NOT NULL default '',
	id 							text NOT NULL default '',
	headers_took 		integer NOT NULL default 0,
	download_took 	integer NOT NULL default 0,
	headers 				json,
	meta 						json,
	hash 						text NOT NULL default ''
);

-- name: create-links
CREATE TABLE links (
	created 				timestamp NOT NULL,
	updated 				timestamp NOT NULL,
	src 						text NOT NULL references urls(url) ON DELETE CASCADE,
	dst 						text NOT NULL references urls(url) ON DELETE CASCADE,
	PRIMARY KEY 		(src, dst)
);

-- name: create-metadata
CREATE TABLE metadata (
	hash 						text NOT NULL default '',
	time_stamp 			timestamp NOT NULL,
	key_id 					text NOT NULL default '',
	subject 				text NOT NULL,
	prev 						text NOT NULL default '',
	meta 						json,
	deleted 				boolean default false
);

-- name: create-snapshots
CREATE TABLE snapshots (
	url 						text NOT NULL references urls(url) ON DELETE CASCADE,
	created 				timestamp NOT NULL,
	status 					integer NOT NULL DEFAULT 0,
	duration 				integer NOT NULL DEFAULT 0,
	meta 						json,
	hash 						text NOT NULL DEFAULT ''
);

-- CREATE TABLE alerts (
-- 	id 					UUID UNIQUE NOT NULL,
-- 	created 		integer NOT NULL,
-- 	updated 		integer NOT NULL,
-- 	dismissed 	boolean default false,
-- 	domain 			UUID references primers(id),
-- 	message 		text
-- );