<?xml version="1.0"?>
<queryset>

<fullquery name="email_handler_process_email_queue.email_handler_get_ids">      
      <querytext>
      select id from incoming_email_queue
      </querytext>
</fullquery>

 
<fullquery name="email_handler_process_email_queue.get_message_info">      
      <querytext>
      
              select tag, content  from incoming_email_queue
		where id = :id
	    
      </querytext>
</fullquery>

 
<fullquery name="email_handler_process_email_queue.delete_from_queue">      
      <querytext>
      delete from incoming_email_queue where id = :id
      </querytext>
</fullquery>

 
<fullquery name="email_handler_process_email_queue.delete_from_queue">      
      <querytext>
      delete from incoming_email_queue where id = :id
      </querytext>
</fullquery>

 
<fullquery name="email_handler_package_id_mem.email_handler_id_get">      
      <querytext>
      
	select package_id from apm_packages
	where package_key = 'email-handler'
    
      </querytext>
</fullquery>

 
</queryset>
