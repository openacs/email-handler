#!/usr/local/bin/perl
#
# Respond to incoming mail message on STDIN
#
# hqm@ai.mit.edu
#
# This script does the following:
#
sub usage () {
    print '
  usage: queue_message.pl db_user db_passwd identifier_tag

  Inserts the data from stdin into a queue table.

  Assumes the following table and sequence are defined in the db:

    create table incoming_email_queue (
            id          integer primary key,
            tag    varchar(256),
            content             clob,           -- the entire raw message content
                                            -- including all headers
            arrival_time        date
    );

    create sequence incoming_email_queue_sequence;

';
}

################################################################
# Global Definitions

$db_user           = shift;
$db_passwd         = shift;
$tag          = shift;

$DEBUG = 1;
$debug_logfile = "/tmp/debug-mailhandler-log.txt"; 

# Oracle access
$ORACLE_HOME="/ora8/m01/app/oracle/product/8.1.6";
$ENV{'ORACLE_HOME'} = $ORACLE_HOME;
$ENV{'ORACLE_BASE'} = "/ora8/m01/app/oracle";
$ENV{'ORACLE_SID'} = "ora8";

$db_datasrc = 'dbi:Oracle:';

################################################################


use DBI;
#use Mail::Address;

use DBD::Oracle qw(:ora_types);


if (!defined $db_user) {
    usage();
    die("You must pass a db user in the command line");
}

if (!defined $db_passwd) {
    usage();
    die("You must pass a db passwd in the command line");
}



#################################################################
## Snarf down incoming msg on STDIN
#################################################################

while (<>) {
    $content .= $_; 
}

# Open the database connection.
$dbh = DBI->connect($db_datasrc, $db_user, $db_passwd,
                     { RaiseError => 1, AutoCommit => 0 })
   || die "Couldn't connect to database";

# This is supposed to make it possible to write large CLOBs
$dbh->{LongReadLen} = 2**20;   # 1 MB max message size 
$dbh->{LongTruncOk} = 0;   

$h = $dbh->prepare(qq[INSERT INTO incoming_email_queue (id, tag,  content, arrival_time) VALUES (incoming_email_queue_sequence.nextval, ?, ?, sysdate)]);


$h->bind_param(2, $content, { ora_type => ORA_CLOB, ora_field=>'content' });

if (!$h->execute($tag, $content)) {
    die "Unable to open cursor:\n" . $dbh->errstr;
}
$h->finish;

$dbh->disconnect;

