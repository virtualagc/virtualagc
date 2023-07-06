#!/usr/bin/python3
# Copyright 2019 Ronald S. Burkey <info@sandroid.org>
#
# This file is part of yaAGC.
#
# yaAGC is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# yaAGC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with yaAGC; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
# Filename:     yaASMexpression.py
# Purpose:      A lightweight evaluator for the kinds of arithmetical
#               expressions evaluated by the LVDC assembler's macro
#               processor.
# Reference:    http://www.ibibio.org/apollo
# Mods:         2019-07-10 RSB  Began playing around with the concept.
#               2023-05-18 RSB  Changes related to the peculiarities
#                               of AS-512/513 vs AS-206RAM.  See the notes 
#                               marked "2023 change" below.
#               2023-05-19 RSB  Changed name from expression.py.
#               2023-07-03 RSB  Added exponential ("**") token, which is new
#                               (and only used once!) in AS-513.
#               2023-07-06 RSB  Added some handling for mangled names of constants.

# My attempt at a minimal arithmetical expression parser for use
# in assembling LVDC code with yaASM.py.  I don't know that it's bug-free,
# but it's probably good enough.  It has to handle:
#	The 4 standard binary operations -, +, *, /.
#	Exponential operation **.
#	Unary operation -.
#	Numerical literals for decimal numbers, including E, B exponentials.
#	Symbolic constants previously assigned numerical values.
# My survey of the code doesn't indicate the need for it, but it also
# handles:
#	Operator precedence.
#	Parenthetical expressions.
#	Unary operation +.
# The shunting-yard algorithm is used, with the only tricky part being 
# tokenizing the original expression.  It's the E exponents and B scales,
# particularly the latter, that make it tricky.  This algorithm doesn't
# actually change any numerical values based on B scaling, but rather
# accumulates all of the B scales and report them separately at the end
# of the computation.  For example,
#	12B5 / 3B2 = 4B3
# or in terms of the actual data structures used internally,
#	{ "number":12, "scale":5 } / { "number":3, "scale":2 } = { "number":4, "scale":3 }
# For addition and subtraction, the scales of the terms and the result
# must all match.

# 2023 change:  The AS-512 and AS-513 source code use constructions not used
# in AS-206RAM, for which I originally wrote this, and are quite inconsistent
# with my original structure for this code.  Specifically, I fixed the 
# following gaps:
#		nBn								Was already accepted
#		(expression)Bn					Was already accepted
#		nB(expression)					Wasn't already accepted
#       (expression1)B(expression2)		Wasn't already accepted
# Additionally, I've made it possible to run this file as a stand-alone 
# program, outside the context of yaASM.py.  Make sure the command-line switch
# "--test-expressions" is used.

# Of all the functions provided here, it is generally only yaEvaluate() that
# is called directly.

import sys
from decimal import Decimal, ROUND_HALF_UP

# Python's native round() function uses a silly method (in the sense that it is
# unlike the expectation of every programmer who ever lived) called "banker's
# rounding", wherein half-integers sometimes round up and sometimes
# round down.  Good for bankers, I suppose, because rounding errors tend to
# sum to zero, but no help whatever for us.  I've stolen the hround() function
# from my Shuttle HAL/S compiler.  It rounds half-integers upward.
# Returns None on error
def hround(x):
	try:
		i = int(Decimal(x).to_integral_value(rounding=ROUND_HALF_UP))
	except:
		#print("Implementation error, non-decimal:", x, file=sys.stderr)
		#sys.exit(1)
		return None
	return i

# Function to pull a numeric literal constant from a string.
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
		bexp = None
	return number,bexp,string,error

# From an input string, outputs an array of tokens plus an error string
# (which is hopefully normally empty).  The tokens potentially present are:
#	"*"					Multiplication
#	"/"					Division
#	"B+"				Binary plus
#	"U+"				Unary plus
#	"B-"				Binary minus
#	"U-"				Unary minus
#   "**"				Exponential
#	"("					Opening parenthesis
#   ")"					Closing parenthesis
#	{ "token":")", "scale":scale }		Closing parenthesis.  Includes binary scale.
#	{ "number":number, "scale":scale }	A number (integer or float as appropriate).
#	SYMBOL					An alphanumeric (with optional periods) name.
def yaTokenize(string):
	rawString = string + ""
	tokens = [""]
	error = ""
	while string != "":
		# The string should always start with a substring
		# that can be validly tokenized, or else with whitespace.
		if string[0] in [" ", "\t", "\n", "\r"]:
			string = string[1:]
		elif string[:2] == "**":
			tokens.append("**")
			string = string[2:]
		elif string[0] in ["*", "/", "(", ")"]:
			tokens.append(string[0])
			string = string[1:]
		elif string[0].isdigit() or string[0] == ".":
			number,bexp,string,error = pullNumber(string)
			if error != "":
				break
			item = {"number": number}
			if bexp != None:
				item["scale"] = bexp
			tokens.append(item)			
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
				item = {"number": number}
				if bexp != None:
					item["scale"] = bexp
				tokens.append(item)			
			else:
				# Must be a unary operator.
				tokens.append("U" + string[0])
				string = string[1:]
		elif string[0] == "B" and string[:2] != "B(" and tokens[-1] == ")":
			bexp = "B"
			string = string[1:]
			if string[:1] in ["-", "+"]:
				bexp += string[:1]
				string = string[1:]
			while string[:1].isdigit():
				bexp += string[:1]
				string = string[1:]
			try:
				tokens[-1] = { "token":")", "scale":int(bexp[1:]) }
			except:
				error = "No digits for binary scaler: " + rawscale
				break
		elif string[0].isalpha():
			token = string[0]
			string = string[1:]
			while string[:1] in [".", "#"] or string[:1].isalnum():
				token += string[0]
				string = string[1:]
			tokens.append(token)
		else:
			error = "Unknown token: '" + string + "'"
			break			
	return tokens[1:],error

# Followed algorithm here:  https://infogalactic.com/info/Shunting-yard_algorithm
precedence = ["**", "U-", "U+", "/", "*", "B+", "B-"]
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
			while len(stack) > 0 and stack[-1] in precedence and precedence.index(token) >= precedence.index(stack[-1]):
				queue.append(stack[-1])
				stack = stack[:-1]
			stack.append(token)
			continue
		if token == "(":
			stack.append(token)
			continue
		try:
			if token == ")" or (type(token) == type({}) and "token" in token and token["token"] == ")"):
				while len(stack) > 0 and stack[-1] != "(":
					queue.append(stack[-1])
					stack = stack[:-1]
				if len(stack) == 0 or stack[-1] != "(":
					error = "Parentheses do not match"
					return queue,error
				stack = stack[:-1]
				try:
					if type(token) == type({}) and "scale" in token:
						queue.append({"scale":token["scale"]})
				except:
					pass
				continue
		except:
			pass
		error = "Expression token = " + str(token) + \
				", tokens = " + str(tokens)
		return queue,error
	while len(stack) > 0:
		token = stack[-1]
		stack = stack[:-1]
		if token == "(": # or (type(token) == type({}) and "token" in token and token["token"] == ")"):
			error = "Parentheses do not match"
			break
		queue.append(token)
	return queue,error

# This function accepts a string (representing an arithmetical expression, 
# possibly including names of predefined constants) and a dictionary of 
# predefined constants with their values.  The values of the constants
# are number/scale dictionaries themselves.  It outputs a triple
#	value,error
# where value is what the string evaluates to numerically in the form of 
# a number/scale dictionary, and error is a hopefully-empty error message.
def yaEvaluate(string, constants):
	value = { "number":0 }
	
	# 2023 change: Everything related to overallScaler is for taking
	# care of ...B(expression).  What we do is to split this into two parts, 
	# namely what's prior to the B and what's after it, and evaluate them
	# separately, as two different expressions.  The 2nd of the expressions
	# turns into overallScaler, which we save until the end of the evaluation
	# of the 1st of the expressions, and then just increment the scale of
	# the evaluated expression by overallScaler.
	fields = string.split("B(")
	overallScaler = 0
	if len(fields) > 1:
		variableScaler = "(" + fields[1]
		string = "B(".join(fields[:-1])
		overallScaler,error = yaEvaluate(variableScaler, constants)
		if error != "":
			return value,error
		if ("scale" in overallScaler and overallScaler["scale"] != 0) \
				or "number" not in overallScaler:
			return value,("Error: Improper scaler expression: "+variableScaler)
		overallScaler = overallScaler["number"]	
	
	# Let's tokenize the string.
	tokens,error = yaTokenize(string)
	if error != "":
		return value,"Error: " + error
	# Let's replace all constant symbols by their numerical values.
	for n in range(0, len(tokens)):
		if type(tokens[n]) != type({}) and tokens[n] in constants:
			item = { "number":constants[tokens[n]]["number"] }
			if "scale" in constants[tokens[n]]:
				item["scale"] = constants[tokens[n]]["scale"]
			tokens[n] = item
	# Let's use the "shunting yard" algorithm to convert the 
	# tokenized version of the expression string to an RPN
	# form of it.
	queue,error = yaShuntingYard(tokens)
	if error != "":
		return value,"Error: " + error
	rpn = []
	for token in queue:
		if type(token) == type({}) and "number" in token:
			item = {"number":token["number"]}
			if "scale" in token:
				item["scale"] = token["scale"]
			rpn.append(item)
		elif token == "U+":
			pass
		elif token == "U-":
			rpn[-1]["number"] = -rpn[-1]["number"]
		elif token == "B+":
			if ("scale" in rpn[-2] and "scale" in rpn[-1]) and rpn[-2]["scale"] != rpn[-1]["scale"]:
				error = "Error: Scale of terms doesn't match"	
			rpn[-2]["number"] += rpn[-1]["number"]
			rpn.pop()
		elif token == "B-":
			if ("scale" in rpn[-2] and "scale" in rpn[-1]) and rpn[-2]["scale"] != rpn[-1]["scale"]:
				error = "Error: Scale of terms doesn't match"
			rpn[-2]["number"] -= rpn[-1]["number"]
			rpn.pop()
		elif token == "*":
			rpn[-2]["number"] *= rpn[-1]["number"]
			if "scale" in rpn[-2] and "scale" in rpn[-1]:
				rpn[-2]["scale"] += rpn[-1]["scale"]
			rpn.pop()
		elif token == "/":
			rpn[-2]["number"] /= rpn[-1]["number"]
			if "scale" in rpn[-2] and "scale" in rpn[-1]:
				rpn[-2]["scale"] -= rpn[-1]["scale"]
			rpn.pop()
		elif token == "**":
			rpn[-2]["number"] = rpn[-2]["number"] ** rpn[-1]["number"]
			rpn.pop()
		elif type(token) == type({}):
			if "scale" in token:
				if "scale" in rpn[-1]:
					rpn[-1]["scale"] += token["scale"]
				else:
					rpn[-1]["scale"] = token["scale"]
	if len(rpn) != 1:
		error = "Error: Could not evaluate expression"
	else:
		value = rpn[0]
	# 2023 change:
	if overallScaler != 0:
		if "scale" in value:
			value["scale"] += overallScaler
		else:
			value["scale"] = overallScaler
	elif value["number"] == -.99999999 and "scale" not in value:
		# This is purely ad hoc.  It relates to the usage of the operand
		# "=(-.99999999)" to apparently convey the notion of a floating-point
		# -1, whereas the syntax rules I've been able to deduce would result in
		# it being an integer -1 (which is a totally different octal value).
		value["scale"] = 0
	return value,error

# Some test code, which accepts the following types of lines on stdin:
#	(empty)			Just prints all defined constants.
#	NAME=EXPRESSION		Creates/modifies a named constant
#	EXPRESSION		Displays the value of an expression
if "--test-expressions" in sys.argv:
	constants = {}
	while True:
		print("> ", end="")
		sys.stdout.flush()
		line = sys.stdin.readline().strip()
		fields = line.split("=")
		if len(fields) == 2:
			value,errors = yaEvaluate(fields[1], constants)
			if errors != "":
				print(errors)
			else:
				constants[fields[0]] = value
		elif line == "":
			for n in constants:
				print(n + " = " + str(constants[n]["number"]) \
					+ "B" + str(constants[n]["scale"]))
		else:
			tokens,error = yaTokenize(line)
			print("Tokens:", tokens)
			value,errors = yaEvaluate(line, constants)
			if errors != "":
				print("Errors:", errors)
				continue
			print("Value:", value, "%09o" % (0o777777776 & hround(value["number"])))
			'''
			queue,error = yaShuntingYard(tokens)
			if errors != "":
				print("Errors:", errors)
				continue
			print("Queue:", queue)
			'''
	
