--
-- packages/email-handler/sql/email-handler-create.sql
--
-- @author Henry Minsky <hqm@arsdigita.com>
-- @creation-date 2000-12-05
-- @cvs-id $Id$
--

create table incoming_email_queue (
       id              integer primary key,
       tag	       varchar(256),
       -- The entire raw message body including all headers
       content	       clob,           
       arrival_time    date
);

create sequence incoming_email_queue_sequence;

-- For testing the email handler
create table email_handler_test (
  from_header     varchar2(4000),
  subject         varchar2(4000),
  body            varchar2(4000)
);

