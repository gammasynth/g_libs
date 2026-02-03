#|*******************************************************************
# timestamp.gd
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
extends RefCounted
## Timestamp is a helper class  with static functions that can give you datestamps, timestamps, or both combined as one stamp String.
class_name Timestamp

# TODO add hijri (AH)
enum DateFormats {MDY, DMY, YDM, YMD}
enum TimeFormats {HMS, SMH, HM, MH, SM, MS, H, M, S}
enum DateTimeFormats {DT, TD}

enum TimeTypes {Second, Minute, Hour}

## Returns a DateTimeStamp with the current date-time. [br] [br]
## Use a different [member DateTimeFormats] for the [param date_time_format] if you don't want the date-time format. (ex: time-date) [br] [br] [br]
## This is simply a function for calling both methods [method stamp_date] and [method stamp_time], at the same time, for a single combined String. [br] [br]
## See documentation for the [method stamp_date] and [method stamp_time] methods for more information.
static func stamp(date_time_format:DateTimeFormats=DateTimeFormats.DT, separate_date_time:bool=true, date_format:DateFormats=DateFormats.MDY, use_month_string:bool=true, abbreviate_month:int=3, time_format:TimeFormats=TimeFormats.HMS, append_timezone_name:bool=false, stringcase:Text.StringCases=Text.StringCases.Kebab, use_utc_time:bool=true, use_string_identifiers:Array[TimeTypes]=[], string_identifiers_length:int=-1, space_string_identifiers:bool=true, separate_string_identifiers:bool=false, use_military_time:bool=false, sizecase:Text.SizeCases=Text.SizeCases.Lower, time:Dictionary = Time.get_time_dict_from_system(use_utc_time), date:Dictionary = Time.get_date_dict_from_system(use_utc_time)) -> String:
	var datestamp:String = stamp_date(date_format, stringcase, use_utc_time, use_month_string, abbreviate_month, sizecase, date)
	var timestamp:String = stamp_time(time_format, append_timezone_name, stringcase, use_utc_time, use_string_identifiers, string_identifiers_length, space_string_identifiers, separate_string_identifiers, use_military_time, sizecase, time)
	
	var datetimestamp:String = ""
	var separator:String = ""; if separate_date_time: separator = Text.get_case_separator(stringcase)
	
	match date_time_format:
		DateTimeFormats.DT: datetimestamp = str(datestamp, separator, timestamp)
		DateTimeFormats.TD: datetimestamp = str(timestamp, separator, datestamp)
	
	return datetimestamp

## Returns a String with the current hour-minute-second. [br] [br]
## Use a different [member TimeFormats] for the [param time_format] if you don't want the hour-minute-second format. (ex: second-minute, just hours) [br] [br]
## Change the [param stringcase] argument to a different [member Text.StringCases] type, to change the symbol/character between the time values. [br] [br]
## The [param use_string_identifiers] argument toggles the use of strings after time values, in the timestamp. (ex: 2 Hours, 1 Minute) [br] [br]
## If [param use_string_identifiers] is an empty Array, which it is by default, then there will be no notation Strings for the Hour, Minute, Second. [br]
## If you want time notations, place one of [member TimeTypes] for each notation within the [param use_string_identifiers] argument. [br][br]
##
## If you want to use some arbitrary other sets of counted time, rather than the current System time or System > Unix time, such as an amount of time collected from a specific start, you can send a custom Dictionary to the [param time] argument. [br]
## By default, [param time] will simply call [method Time.get_time_dict_from_system], and pass to it the [param use_utc_time] as an argument, which returns the current System time or System > Unix time. [br] [br]
## If you are using a custom [param time] Dictionary argument, consider/keep in mind that the [param append_timezone_name] argument being true will append what is returned from [method Time.get_time_zone_from_system].
##
## See the documentation of the [method Time.get_time_dict_from_system] method for usage of the [param use_utc_time] argument.
static func stamp_time(time_format:TimeFormats=TimeFormats.HMS, append_timezone_name:bool=false, stringcase:Text.StringCases=Text.StringCases.Kebab, use_utc_time:bool=false, use_string_identifiers:Array[TimeTypes]=[], string_identifiers_length:int=-1, space_string_identifiers:bool=true, separate_string_identifiers:bool=false, use_military_time:bool=false, sizecase:Text.SizeCases=Text.SizeCases.Lower, time:Dictionary = Time.get_time_dict_from_system(use_utc_time)) -> String:
	# hour, minute, and second
	
	var hour: int = time.get("hour")
	var minute: int = time.get("minute")
	var second: int = time.get("second")
	
	var hour_string: String = str(hour)
	var minute_string: String = str(minute)
	var second_string: String = str(second)
	
	var meridian:String = ""
	if not use_military_time:
		if hour >= 12: 
			meridian = "pm"
			if hour == 12: hour_string = str(hour)
			else: hour_string = str(hour - 12)
		else: meridian = "am"
		meridian = Text.format_size_case(meridian, sizecase)
	
	var separator:String = Text.get_case_separator(stringcase)
	
	var h = ""
	var m = ""
	var s = ""
	if use_string_identifiers.size() > 0:
		h = "Hours"
		m = "Minutes"
		s = "Seconds"
		if string_identifiers_length != -1:
			h = h.substr(0, string_identifiers_length)
			m = m.substr(0, string_identifiers_length)
			s = s.substr(0, string_identifiers_length)
		
		h = Text.format_size_case(h, sizecase)
		m = Text.format_size_case(m, sizecase)
		s = Text.format_size_case(s, sizecase)
		if space_string_identifiers:
			h = str(" " + h)
			m = str(" " + m)
			s = str(" " + s)
			meridian = str(" " + meridian)
		if separate_string_identifiers:
			h = str(separator + h)
			m = str(separator + m)
			s = str(separator + s)
			meridian = str(separator + meridian)
	
	if not use_string_identifiers.has(TimeTypes.Hour): h = ""
	if not use_string_identifiers.has(TimeTypes.Minute): m = ""
	if not use_string_identifiers.has(TimeTypes.Second): s = ""
	
	var tz:String = ""
	if append_timezone_name: 
		tz = Text.acronym(Time.get_time_zone_from_system().get("name"), Text.StringCases.Space, -1, sizecase)
		tz = str(separator + tz)
		if not tz.right(1).containsn("t"): tz = Text.format_size_case(str(tz + "t"), sizecase)
	
	var timestamp:String = ""
	match time_format:
		TimeFormats.HMS: timestamp = str(hour_string, h, meridian, separator, minute_string, m, separator, second_string, s, tz)
		TimeFormats.SMH: timestamp = str(second_string, s, separator, minute_string, m, separator, hour_string, h, meridian, tz)
		TimeFormats.HM: timestamp = str(hour_string, h, meridian, separator, minute_string, m, tz)
		TimeFormats.MH: timestamp = str(minute_string, m, separator, hour_string, h, meridian, tz)
		TimeFormats.SM: timestamp = str(second_string, s, separator, minute_string, m, tz)
		TimeFormats.MS: timestamp = str(minute_string, m, separator, second_string, s, tz)
		TimeFormats.H: timestamp = str(hour_string, h, meridian, tz)
		TimeFormats.M: timestamp = str(minute_string, m, tz)
		TimeFormats.S: timestamp = str(second_string, s, tz)
	
	return timestamp

## Returns a String with the current month-day-year. [br][br]
## Change the [param date_format] to a different [member DateFormats], if you want an order other than month-day-year (ex: year-day-month) [br][br]
## Change the [param stringcase] to another [member Text.StringCases] to change the symbol used between the month/day/year (ex: Text.StringCases.Money = month$day$year)
## If [param use_month_string] is false, then abbreviate_month and sizecase do not affect anything, as the month would be a number instead of text. [br][br][br]
##
## If you want to use some arbitrary other sets of counted time, rather than the current System time or System > Unix time, such as an amount of time collected from a specific start, you can send a custom Dictionary to the [param date] argument. [br]
## By default, [param date] will simply call [method Time.get_date_dict_from_system], and pass to it the [param use_utc_time] as an argument, which returns the current System date or System > Unix date. [br] [br]
static func stamp_date(date_format:DateFormats=DateFormats.MDY, stringcase:Text.StringCases=Text.StringCases.Kebab, use_utc_time:bool=false, use_month_string:bool=true, abbreviate_month:int=3, sizecase:Text.SizeCases=Text.SizeCases.Lower, date:Dictionary = Time.get_date_dict_from_system(use_utc_time)) -> String:
	# TODO add hijri calender (AH)
	# year, month, day, and weekday
	
	var year:String = str(date.get("year"))
	var day:String = str(date.get("day"))
	
	var month_num:int = int(date.get("month"))
	var month:String = Calendar.Months.keys().get(month_num - 1)
	
	if use_month_string:
		if abbreviate_month: month = month.substr(0, 3)
		month = Text.format_size_case(month, sizecase)
	else:
		month = str(month_num)
	
	var separator:String = Text.get_case_separator(stringcase)
	
	var datestamp:String = ""
	match date_format:
		DateFormats.MDY: datestamp = str(month, separator, day, separator, year)
		DateFormats.YDM: datestamp = str(year, separator, day, separator, month)
		DateFormats.DMY: datestamp = str(day, separator, month, separator,  year)
		DateFormats.YMD: datestamp = str(year, separator, month, separator, day)
	return datestamp
