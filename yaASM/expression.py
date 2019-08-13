#!/usr/bin/python3
# My attempt at a minimal arithmetical expression parser for use
# in assembling LVDC code with yaASM.py.  It has to handle:
#	The 4 standard binary operations -, +, *, /
#	Unary operation -.
#	Numerical literals for decimal numbers, including E, B exponentials
#	Symbolic constants previously assigned numerical values
# My survey of the code does indicate the need for it, but:
#	Operator precedence
#	Parenthetical expressions
#	Unary operation +.
# I think the shunting-yard algorithm can be used, with the only tricky
# part being tokenizing.  It's the E,B exponentials that make it tricky.

import sys

# The leading portion of the input string is known to be a number
# (optional leading + or -, substring of at least on digit with
# one optional decimal point in it somewhere, and optional E exponent
# and/or B scaling, in either order, with optional + or - in them).
# The function pulls out the number (with its optional exponent) and
# the optional scaling separately.  The input string is shortened 
# accordingly and output as well.  If any of that goes wrong, an 
# error message is also output.  The syntax is
#	number,bexp,error,outputString = pullNumber(inputString)
def pullNumber(string):
	number = ""
	if string[:1] in ["-", "+"]:
		number = string[0]
		string = string[1:]
	bexp = ""
	pre = False
	post = False
	b = True
	e = True
	error = ""
	while string[:1].isdigit():
		number += string[:1]
		string = string[1:]
		pre = True
	if string[:1] == ".":
		number += string[:1]
		string = string[1:]
	while string[:1].isdigit():
		number += string[:1]
		string = string[1:]
		post = True
	if string[:1] == "B":
		bexp = "B"
		b = False
		string = string[1:]
		if string[:1] in ["-", "+"]:
			bexp += string[:1]
			string = string[1:]
		while string[:1].isdigit():
			bexp += string[:1]
			string = string[1:]
			b = True
	if string[:1] == "E":
		number += "E"
		e = False
		string = string[1:]
		if string[:1] in ["-", "+"]:
			number += string[:1]
			string = string[1:]
		while string[:1].isdigit():
			number += string[:1]
			string = string[1:]
			e = True
	if bexp == "" and string[:1] == "B":
		bexp = "B"
		b = False
		string = string[1:]
		if string[:1] in ["-", "+"]:
			bexp += string[:1]
			string = string[1:]
		while string[:1].isdigit():
			bexp += string[:1]
			string = string[1:]
			b = True
	if not pre and not post:
		error = "No digits in number"
	elif not b:
		error = "No digits in scale"
	elif not e:
		error = "No digits in exponent"
	else:
		try:
			number = float(number)
			if number.is_integer():
				number = int(number)
		except:
			error = "Not a number"
	if bexp != "" and error == "":
		bexp = int(bexp[1:])
	else:
		bexp = 0
	return number,bexp,string,error

# From an input string, outputs an array of tokens plus an error string
# (which is hopefully normally empty).  The tokens potentially present are:
#	"*"					Multiplication
#	"/"					Division
#	"B+"					Binary plus
#	"U+"					Unary plus
#	"B-"					Binary minus
#	"U-"					Unary minus
#	"("					Opening parenthesis
#	{ "token":")", "scale":scale }		Closing parenthesis.  Includes binary scale.
#	{ "number":number, "scale":scale }	A number (integer or float as appropriate).
#	SYMBOL					An alphanumeric (with optional periods) name.
def yaTokenize(string):
	tokens = [""]
	error = ""
	while string != "":
		# The string should always start with a substring
		# that can be validly tokenized, or else with whitespace.
		if string[0] in [" ", "\t", "\n", "\r"]:
			string = string[1:]
		elif string[0] in ["*", "/", "(", ")"]:
			tokens.append(string[0])
			string = string[1:]
		elif string[0].isdigit():
			number,bexp,string,error = pullNumber(string)
			if error != "":
				break
			tokens.append({"number": number, "scale": bexp})			
		elif string[0] in ["-", "+"]:
			# This could be unary or binary operators, or 
			# the first part of a literal number, and we
			# need to detect which. The first step is
			# detecting whether or not they're binary operators,
			# and that depends on what the previous token was.
			if tokens[-1] not in ["", "*", "/", "(", "B+", "B-"]:
				# Must be a binary operator.
				tokens.append("B" + string[0])
				string = string[1:]
			elif string[1:][:1].isdigit() or string[1:][:1] == ".":
				# Must be part of a numeric literal.
				number,bexp,string,error = pullNumber(string)
				if error != "":
					break
				tokens.append({"number": number, "scale": bexp})			
			else:
				# Must be a unary operator.
				tokens.append("U" + string[0])
				string = string[1:]
		elif string[0] == "B" and tokens[-1] == ")":
			bexp = "B"
			string = string[1:]
			if string[:1] in ["-", "+"]:
				bexp += string[:1]
				string = string[1:]
			while string[:1].isdigit():
				bexp += string[:1]
				string = string[1:]
			tokens[-1] = { "token":")", "scale":bexp }
		elif string[0].isalpha():
			token = string[0]
			string = string[1:]
			while string[:1] == "." or string[:1].isalnum():
				token += string[0]
				string = string[1:]
			tokens.append(token)
		else:
			error = "Unknown token: '" + string + "'"
			break			
	return tokens[1:],error

# Followed algorithm here:  https://infogalactic.com/info/Shunting-yard_algorithm
precedence = ["U-", "U+", "*", "/", "B+", "B-"]
def yaShuntingYard(tokens):
	queue = []
	stack = []
	error = ""
	for token in tokens:
		try:
			if "number" in token:
				queue.append(token)
				continue
		except:
			pass
		if token in precedence:
			while len(stack) > 0 and stack[-1] in precedence and precedence.index(token) < precedence.index(stack[1]):
				queue.append(stack[-1])
				stack = stack[:-1]
			stack.append(token)
			continue
		if token == "(":
			stack.append(token)
			continue
		try:
			if token["token"] == ")":
				while len(stack) > 0 and stack[-1] != "(":
					queue.append(stack[-1])
					stack = stack[:-1]
				if len(stack) == 0 or stack[-1] != "(":
					error = "Parentheses do not match"
					return queue,error
				stack = stack[:-1]
				continue
		except:
			pass
		error = "Implementation error"
		return queue,error
	return queue,error

# This function accepts a string (representing an arithmetical expression, 
# possibly including names of predefined constants) and a dictionary of 
# predefined constants with their values.  It outputs a pair
#	value,error
# where value is what the expression evaluates to numerically, and error
# is a hopefully-empty error message.
def yaEvaluate(string, constants):
	value = 0
	# Let's tokenize the string.
	tokens,error = yaTokenize(string)
	if error != "":
		return value,error
	# Let's replace all constant symbols by their numerical values.
	for n in range(0, len(tokens)):
		if tokens[n] in constants:
			tokens[n] = constants[tokens[n]]
	# Let's use the "shunting yard" algorithm to convert the 
	# tokenized version of the expression string to an RPN
	# form of it.
	queue,error = yaShuntingYard(tokens)
	if error != "":
		return queue,error
	# Let's evaluate the RPN form of the expression.
	value = queue
	return value,error

constants = {}
for line in sys.stdin:
	line = line.strip()
	print(line)
	tokens,errors = yaTokenize(line)
	if errors != "":
		print(errors)
		break
	#print(tokens)
	value,errors = yaEvaluate(tokens, constants)
	if errors != "":
		print(errors)
		break;
	print(value)
	
	
