# tcl/email-handler.tcl

ad_library {
    
  Scan incoming email queue, and dispatch to assigned handler
  
    @author hqm@arsdigita.com 
    @cvs-id $Id$
}


#
# Scan the incoming email queue, looking for messages
#

proc email_handler_map_tagged_message {tag msg} {
    # Get a list of tag|procedure_name pairs
    set pairs [ad_parameter -package_id [email_handler_package_id] "DispatchTable" email-handler {}]
    foreach pair $pairs {
	set pair_list [split $pair "|"]
	set tag [lindex $pair_list 0]
	set tcl_proc_to_invoke [lindex $pair_list 1]
	if { [string compare $tag $tag] == 0 } {
	    $tcl_proc_to_invoke $msg
	    return ""
	}
    } 
    ns_log Warning "email_handler_map_tagged_message couldn't find anything to do with a tag of \"$tag\"
Message:
$msg
"
}

################################################################

proc email_handler_process_email_queue {} {
    # loop over queue, running process_ticket_message $db $message
    # be careful to do this as small transactions to not hold up the
    # database too long.
    set id_list [db_list email_handler_get_ids "select id from incoming_email_queue"]

    foreach id $id_list {
	db_transaction {
	    db_1row get_message_info {
              select tag, content  from incoming_email_queue
		where id = :id
	    }
	    ns_log debug "email queue processing queued_msg $id"
	    email_handler_map_tagged_message $tag $content
	    db_dml delete_from_queue "delete from incoming_email_queue where id = :id"
	    ns_log debug "email queue deleted queued_msg $id"
	} on_error {
	    ns_log Warning "email queue processing; transaction ABORTED! err: $errmsg"
	    # Remove the offending message from the queue or it will probably 
	    # trigger the same error next time.
	    catch { db_dml delete_from_queue "delete from incoming_email_queue where id = :id" }
	    global errorInfo errorCode
	    ns_log Warning "email_handler_process_email_queue: delete_from_queue error $errorInfo"
	}
    }
    db_release_unused_handles
}


ad_proc -public email_handler_package_id {} {

    @return The object id of the email_handler if it exists, 0 otherwise.
} {
    return [util_memoize [list email_handler_package_id_mem]]
}
	

proc email_handler_package_id_mem {} {
    return [db_string email_handler_id_get {
	select package_id from apm_packages
	where package_key = 'email-handler'
    } -default 0]
}

################################################################
# Use shared variable to keep an extra scheduling from
# happening when script is re-sourced

ns_share -init {set email_scheduler_installed 0} email_scheduler_installed

if {!$email_scheduler_installed} {
    set email_scheduler_installed 1
    set interval [ad_parameter -package_id [email_handler_package_id] QueueSweepInterval email-handler 600]
    ns_log Notice "email-handler-procs.tcl scheduling email_handler_process_email_queue to run every $interval seconds."
    ad_schedule_proc -thread t $interval email_handler_process_email_queue
}

