# email-handler-test.tcl


proc email_handler_test {msg} {
    set headers [parse_email_message $msg]

    set msgbody        [ns_set iget $headers "message_body"]
    set from_hdr       [ns_set iget $headers "from"]
    set subject_hdr    [ns_set iget $headers "subject"]

    db_dml "email_test" {insert into email_handler_test (from_header, subject, body) 
    values (:from_hdr, :subject_hdr, :msgbody)}
    ns_log Notice "email_handler_test from=$from_hdr subject=$subject_hdr"
}
