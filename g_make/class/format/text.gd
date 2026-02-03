#|*******************************************************************
# text.gd
#*******************************************************************
# This file is part of g_libs.
# 
# g_libs is an open-source software library.
# g_libs is licensed under the MIT license.
# 
# https://github.com/gammasynth/g_libs
#*******************************************************************
# Copyright (c) 2025 AD - present; 1447 AH - present, Gammasynth.  
# Gammasynth (Gammasynth Software), Texas, U.S.A.
# 
# This software is licensed under the MIT license.
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# 
#|*******************************************************************

class_name Text

## Types of cases related to the capitalization of letter characters.
enum SizeCases {None, Upper, Lower, Title, Pascal}
## Types of cases related to the types of symbol/characterset separation that can be placed between multiple, or sets of, other String values.
enum StringCases {Kebab, Snake, Space, Comma, List, Nest, Dots, Tilde, Yell, At, Hashtag, Money, Percent, Up, And, Star, Plus, Pipe, Colon, Semicolon, Forward, Backward, Slash, Backslash, Custom}
static var custom_separator:String = ""

## RichText BBCode Colors
enum COLORS {black, red, green, yellow, blue, magenta, pink, purple, cyan, white, orange, gray}
const COLOR_NAMES: Array[String] = ["black", "red", "green", "yellow", "blue", "magenta", "pink", "purple", "cyan", "white", "orange", "gray"]

## Returns the given [param string] argument formatted to the given [param sizecase]. [br] [br] [br]
## See [method String.to_lower], [method String.to_upper], [method String.capitalize], [method String.to_pascal_case] for more information.
static func format_size_case(string:String, sizecase:SizeCases) -> String:
	match sizecase:
		Text.SizeCases.Lower: string = string.to_lower()
		Text.SizeCases.Upper: string = string.to_upper()
		Text.SizeCases.Title: string = string.capitalize()
		Text.SizeCases.Pascal: string = string.to_pascal_case()
	return string

## Returns a String with the corresponding symbol or combination of characters for the given [param case]. [br] [br]
## If using [member StringCases.Custom], then the returned separator will be whatever [member custom_separator] is currently (or was last/most recently) set to.
static func get_case_separator(case:StringCases) -> String:
	var separator:String = ""
	match case: 
		StringCases.Kebab: separator = "-"
		StringCases.Snake: separator = "_"
		StringCases.Space: separator = " "
		StringCases.Comma: separator = ","
		StringCases.List: separator = ", "
		StringCases.Nest: separator = "."
		StringCases.Dots: separator = "..."
		#StringCases.Pascal: separator = ""; print("Text.gd | Warning! Tried to call get_case_separator on Text.Cases.Pascal! Returning empty String...")
		StringCases.Tilde: separator = "~"
		StringCases.Yell: separator = "!"
		StringCases.At: separator = "@"
		StringCases.Hashtag: separator = "#"
		StringCases.Money: separator = "$"
		StringCases.Percent: separator = "%"
		StringCases.Up: separator = "^"
		StringCases.And: separator = "&"
		StringCases.Star: separator = "*"
		StringCases.Plus: separator = "+"
		StringCases.Pipe: separator = "|"
		StringCases.Colon: separator = ":"
		StringCases.Semicolon: separator = ";"
		StringCases.Forward: separator = ">"
		StringCases.Backward: separator = "<"
		StringCases.Slash: separator = "/"
		StringCases.Backslash: separator = "\\"
		StringCases.Custom: separator = custom_separator
	return separator

## Returns the given [param text] argument as String with the given [param with_color] wrapped as bbcode. 
## Optionally call [method center] on the [param text] by enabling the [param centered] argument. [br][br]
## For quickly coloring (or not) rich text; in either [method print_rich] or in [class RichTextLabel]s that have [member RichTextLabel.bbcode_enabled] set to true.
static func color(text:String, with_color:COLORS, centered:bool=false, do:bool=true) -> String:
	if not do: return text
	var clr = COLOR_NAMES[with_color]
	text = str("[color=" + clr + "]" + text + "[/color]")
	if centered: return center(text)
	return text

## Returns the given [param text] argument as String with the given [param with_color] wrapped as bbcode. [br][br]
## For quickly centering (or not) rich text; in either [method print_rich] or in [class RichTextLabel]s that have [member RichTextLabel.bbcode_enabled] set to true.
static func center(text:String, do:bool=true) -> String:
	if not do: return text
	return str("[center]" + text + "[/center]")

static func acronym(text:String, separator_type:StringCases=StringCases.Space, splits:int=-1, sizecase:SizeCases=SizeCases.None, do:bool=true) -> String:
	if not do: return text
	
	var abb:String = ""
	
	var separator = get_case_separator(separator_type)
	var new_text:String = text
	
	var chops:int = 0
	var allowed:bool = true
	
	while new_text.containsn(separator) and allowed:
		var chop:String = new_text.substr(0, new_text.findn(separator) - 1)
		abb = str(abb + chop.substr(0,1))
		new_text = new_text.substr(new_text.findn(separator))
		if new_text.length() > 1: new_text = new_text.substr(1)
		chops += 1
		if splits > 0:
			if chops > splits: allowed = false
	
	abb = Text.format_size_case(abb, sizecase)
	
	return abb
