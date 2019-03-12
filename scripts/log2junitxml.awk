##
# Convert the output form TeX that has been filtered by parselog.awk
# into a JUnit XML format
#
# This takes the preprocessed output from parselog.awk and
# tries to find warnining/error/failure messages and formats them
# to be parsed by a JUnit XML consumer like Jenkins or other CI
# tools.

BEGIN{
	for (i=0; i<=127; i++){
		c=sprintf("%c", i);
		ord[c] = i
	}
	FS="|";
}

function to_xml_text(str, i, tmp, c, r, printable){
		r="";
		for (i=1; i<=length(str); i++){
				c=substr(str, i, 1);
				tmp = ord[c];
				if (tmp == "" ) tmp = 0xff; # Disregard chars that are not found
				# like UTF-8
				printable = 1;
				# mask only things that might break XML, leave UTF-8
				# data pass the filter
				if (tmp < 0x30)
					printable = 0;
				if ( (tmp >= 0x3A) && (tmp <= 0x40) )
					printable = 0;
				if ( printable ) {
					r = r c;
				} else {
					r = r sprintf("&#x%02x;",tmp);
			}
	}
	return r
}

BEGIN{
	print "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
	error_count = 0;
	failure_count = 0;
	total_count = 0;
	}

{
	#print to_xml_text($0)
	filename=$1;
	trace=$2;
	gsub("->", "\n ", trace);
	message="";
	for (i=3; i<=NF; i++)
		message=message "|" $i;
	# Remove trailing pipe and spaces
	message = substr(message, 2);

	if (filename!=old_filename) total_count += 1;
	files[filename]+=total_count;
}

function new_msg(class){
	in_type=class;
	class_count[class]+=1;
	filename_count[filename]+=1;
	id = filename":"filename_count[filename];
	classes[id]=class;
    traces[id]=trace;
	}

message~/^! Package.*Error:/{
	error_count += 1;
	id=error_count;
	new_msg("error");
	}

message~/^!.*TeX Error:/{
	error_count += 1;
	id=error_count;
	new_msg("error");
	}

message~/TeX Warning:/ || message~/^Package .* Warning:/{
	error_count += 1;
	id=error_count;
	new_msg("error");
	}

message~/^Undefined control/{
	failure_count+=1;
	id=failure_count;
	new_msg("fail");
	}

#message~/type command to continue.$/{
#	failure_count+=1;
#	id=failure_count;
#	new_msg("fail");
#	}

(message=="")&&(in_type!=""){
#	print "msg ended "id;
#	print "file "files[id]
#	print messages[id];
	in_type = "";
	}

in_type!=""{
	messages[id]=messages[id]"\n"message;
	}

{
	old_filename = filename;
	}

END{
	print "<testsuite name=\"basefile.tex\">";
	for ( file in files ){
			print (" <testcase name=\""to_xml_text(file)"\" classname=\""to_xml_text(file)"\">");
			max = filename_count[file];
			print max;
			for (i=1; i<=max; i++){
					type = "error";
					id=file":"i;
					if (classes[id]=="fail")
						type="failure";

					print "   <"type" message=\""to_xml_text(messages[id])"\">";
					print "<![CDATA[";
					print " Include stack:" traces[id];
					print "\nMessages:\n" messages[id];
					print "]]>";
					print "   </"type">";
				}
			print("  <system-out>");
			for (i=1; i<=max; i++){
				# Dump error messages here
				id=file":"i;
				print to_xml_text(messages[id]);
			}
			print("  </system-out>");
			print (" </testcase>");
		}
	print "</testsuite>";

	}
