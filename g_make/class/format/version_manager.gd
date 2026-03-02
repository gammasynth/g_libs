#|*******************************************************************
# version_manager.gd
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
## A static helper class for working with version Strings.
class_name VersionManager

## An enumeration describing the possible differences a version state can have, compared to another version.
enum Differences {
	Unreleased_Major,
	Unreleased_Minor,
	Unreleased_Patch,
	Up_To_Date,
	Outdated_Major,
	Outdated_Minor,
	Outdated_Patch
}

## Returns the next part (major, minor, patch) of the [param version], if [param up], else will return the rest of the string after that part.
static func chop_dot(version:String, up:bool = true) -> String: 
	if up: return version.left(version.find("."))
	return version.right(version.find(".") + 1)

## Returns a Dictionary object containing keys for major, minor, and patch, with values from the inputted [param version].
static func version_dictionary(version:String) -> Dictionary:
	var vs:String = version
	var major:String = chop_dot(vs)
	vs = chop_dot(vs, false)
	
	var minor:String = chop_dot(vs)
	vs = chop_dot(vs, false)
	
	var patch:String = vs
	
	var version_data:Dictionary = {}
	version_data.set("major", major)
	version_data.set("minor", minor)
	version_data.set("patch", patch)
	
	return version_data

## Will return true if [param other_version] is a later update than [param version] is.
static func is_version_newer(version:String, other_version:String) -> bool:
	var difference:Differences = version_comparison(version, other_version)
	match difference:
		Differences.Unreleased_Major: return false
		Differences.Unreleased_Minor: return false
		Differences.Unreleased_Patch: return false
		Differences.Up_To_Date: return false
		Differences.Outdated_Major: return true
		Differences.Outdated_Minor: return true
		Differences.Outdated_Patch: return true
	return true

## Will return a [member Differences] based on comparison of [param other_version] to [param version].
static func version_comparison(version:String, other_version:String) -> Differences:
	
	var version_data:Dictionary = version_dictionary(version)
	var other_version_data:Dictionary = version_dictionary(other_version)
	
	var difference:Differences = Differences.Up_To_Date
	
	var patch_prog:String = version_data.get("patch")
	var other_patch_prog:String = other_version_data.get("patch")
	if int(patch_prog) > int(other_patch_prog): difference = Differences.Unreleased_Patch
	if int(patch_prog) < int(other_patch_prog): difference = Differences.Outdated_Patch
	
	var minor_prog:String = version_data.get("minor")
	var other_minor_prog:String = other_version_data.get("minor")
	if int(minor_prog) > int(other_minor_prog): difference = Differences.Unreleased_Minor
	if int(minor_prog) < int(other_minor_prog): difference = Differences.Outdated_Minor
	
	var major_prog:String = version_data.get("major")
	var other_major_prog:String = other_version_data.get("major")
	if int(major_prog) > int(other_major_prog): difference = Differences.Unreleased_Major
	if int(major_prog) < int(other_major_prog): difference = Differences.Outdated_Major
	
	return difference
