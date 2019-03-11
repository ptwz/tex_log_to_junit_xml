BEGIN{ in_msg = 0;}

/Package .* Info:/{
	in_msg = 1
	}


/Package .* Warning:/{
	in_msg = 1
	}

/LaTeX Warning:/{
	in_msg = 1;
}

/^Overfull / || /^Underfull /{
	in_msg = 1;
	}

/^$/ || /^)/{
	in_msg = 0;
}

in_msg{
	gsub("[()]","#");
	}

{
	#print in_msg"|"$0;
	cur_line = cur_line $0;

	if (length($0) >= 79){
		next;
		}
	print cur_line;
	cur_line = "";
}
