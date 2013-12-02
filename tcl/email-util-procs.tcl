# email-utils.tcl

ad_library {

    utilities to process incoming emails

    @author  hqm@ai.mit.edu
    @creation-date Dec 4, 2000
    @cvs-id $Id$
}


ad_proc parse_email_message {message} { 
 Parse an RFC 822 email message, and return an ns_set with headers 
and body text.
<p>
Message body will be returned associated with keyword "message_body".
<p>
This attempts to read multiline headers.
} {
    set lines [split $message "\n"]
    set result [ns_set create]
    set in_body 0
    set last_header ""
    set header_value ""
    set header ""
    foreach line $lines {
	if {$line == {}} {
	    set in_body 1
	    if {$last_header != ""} {
		ns_set update $result $last_header $header_value
	    }
	} 
	if {$in_body} {
	    append msgbody "$line\n"
	} else {
	    # Parse Headers
	    # Is this a continuation of a multiline header?
	    # (i.e., a header line which starts with a whitespace?)
	    if {[regexp {^[ 	]} $line match]} {
		# append to accumulating value
		append header_value "\n" $line
	    } else {
		# Its a new header line.
		# Store the previously accumulated header if it exists
		if {$last_header != ""} { 
		    ns_set update $result $last_header $header_value
		    set header_value ""
		}
		set value ""
		regexp {^([^: 	]*): (.*)} $line match header value
		append header_value $value
		set last_header $header
	    }
	}
    }
    ns_set update $result message_body $msgbody
    return $result
}

ad_proc send_email_attachment_from_file {{-to "" -from "" -subject "" -msg "" -src_pathname "" -dst_filename ""}} {Send an email message using sendmail, with a MIME base64 encoded attachment of the file src_pathname. src_pathname is an absolute pathname to a file in the local server filesystem. dst_filename is the name given to the file attachment part in the email message.} {

    set fd [open $src_pathname r]
    fconfigure $fd -encoding binary
    set content [read $fd]
    close $fd

    set encoded_data [ns_uuencode $content]

    set mime_boundary "__==NAHDHDH2.28ABSDJxjhkjhsdkjhd___"

    append body "--$mime_boundary
Content-Type: text/plain; charset=\"us-ascii\"

$msg

--$mime_boundary
Content-Type: application/octet-stream; name=\"$dst_filename\"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=\"$dst_filename\"

"
    append body $encoded_data
    append body "\n--[set mime_boundary]--\n"
    acs_mail_lite::send -to_addr $to -from_addr $from -subject $subject -body $body -extraheaders [list \
      [list "Mime-Version" "1.0"] \
      [list "Content-Type" "multipart/mixed; boundary=\"$mime_boundary\""] \
    ]

}