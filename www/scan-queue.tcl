# email-handler/scan-queue.tcl

# Force a scan of the incoming email queue

email_handler_process_email_queue

doc_return 200 text/html "OK"
