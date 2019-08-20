##
# Prepare a TeX log file for parsing
#
# This script removes brackets from lines TeX quoted from the original
# input in order to avoid breaking a bracket-searching parser.
# Also it removes the autmatic console output wrapping done by latex
# by default (whose effect can be lessened in texmf.cnf) using
#  error_line = 254
#  half_error_line = 128
#  max_print_line = 65534

BEGIN{ in_msg = 0;}

{
	cur_line = cur_line $0;
}

(in_msg==1) && ( cur_line~/^$/ || cur_line~/)$/ || cur_line~/^)/ || cur_line~/^[(][./]/ || cur_line~/^[<]/ || cur_line~/^\[/ ) {
	in_msg = 0;
}

(in_msg==3) && ( cur_line~/^$/ ) {
	# Message class for Over/Underfull
	in_msg = 0;
}

cur_line~/Package .* Info:/{
	in_msg = 1
	}

cur_line~/^! Undefined control sequence/{
	in_msg=1;
	}

cur_line~/Package .* Warning:/{
	in_msg = 1
	}

cur_line~/^File/ || cur_line~/Graphic file/{
    in_msg = 1;
    }

cur_line~/Package .* Error:/{
	in_msg = 1
	}

cur_line~/TeX Warning:/{
	in_msg = 1;
}

cur_line~/TeX Error:/{
	in_msg = 1;
}

cur_line~/^Overfull / || cur_line~/^Underfull /{
	in_msg = 3;
	}

cur_line~/This is .*TeX, Version/{
	in_msg = 2;
	}

cur_line~/^\*\*/ && (in_msg==2){
	in_msg = 0;
	}

{
	#print in_msg"|"$0;

	if (length($0) > 79){
		next;
		}
    if (in_msg) gsub("[)(]","#",cur_line);
	print cur_line;
	cur_line = "";
}
