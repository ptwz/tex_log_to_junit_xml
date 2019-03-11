##
# Parse a TeX log file into a better machine readable form
#
# This takes the round-bracket notation used by TeX nd transforms it into
# a kind of greppable "stack-strace" form.
#
# Note:
# It is meant to be used behind a pipe from preprocess.awk which does strip
# unnecessary or potentially misleading brackets.
# 
# Example input:
# (test.tex (first-include.tex
# LaTeX Error: Blah...
#
# ))
#
# Example output:
# test.tex->first-include.tex|1|LaTex Error: Blah...


BEGIN{
	RS="[()]";
	FS="[\n\r]";
	OFS="|";
	state = "idle";
	stack_depth = 0;
} 

function stack_repr(i,r){
	r = ""
	for (i=0; i<stack_depth; i++) r = r "->" stack[i];
	return r;
	}

function push(name){
	stack[stack_depth++]=name;
	#print "PUSH"name"PUSH"$0;
	}

function pop(){
	if (stack_depth==0)
		return;
	r = stack[--stack_depth];
	#print "POP"r"POP";
	#print_stack();
	return r
	}

function peek(j){
	j=stack_depth-1;
	while ( (j>0) && (stack[j]=="FLUFF")) { j-=1; }

	return stack[j];
}

function done_here(){
	next;
	}

{
	#print "LT="LT" RT="RT" $0=|"$0"|";
	skip = 0;
}

(/\.tex/ || /\.sty/ || /\.cls/ || /\.def/ || /\.clo/ || /\.ldf/) && (LT=="("){
	x= $1;
	push(x);
	skip = 1;
	}

(skip==0) && (LT=="("){
	# Wenn nicht behandelt -> Fluff
	push("FLUFF");
	}

skip==0{
	for (i=1; i<=NF; i++){
		print peek(), i, $i;
		}
	}

RT~")"{
	x=pop();
	}

{
	LT=RT;
	done_here();
	}
