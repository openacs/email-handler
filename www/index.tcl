# email-handler/index.tcl

ad_page_contract {
  
   Show the test database table for testing email handler

} {

}

append page "[ad_header "Email Handler Test Table"]
<h1>Email Handler Test Table</h1>

Checking APM parameters: 
\[email_handler_package_id\] = [email_handler_package_id]
<p>
 \[ad_parameter -package_id  \[email_handler_package_id\] QueueSweepInterval email-handler 600\] = 
 [ad_parameter -package_id [email_handler_package_id] QueueSweepInterval email-handler 600]
<p>

Messages sent to 'test-email' at this host should be being placed automatically
into this table by the email handler test routine.

<table border=1>
<tr><th>From</th><th>Subject</th><th>Message</th></tr>
"

db_foreach test_items {
    select from_header, subject, body from email_handler_test
} {
    append page "<tr><td>$subject</td><td>$from_header</td><td>$body</td></tr>"
}
append page "</table>"


doc_return 200 text/html $page