#|*******************************************************************
# english.gd
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
class_name English

enum LetterTypes {Any, Consonant, Vowel, SpecialVowel, Silent}

enum Letters {A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z}
const LettersCaptialized : Array[String] = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
const LettersLowercase : Array[String] = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]

enum Consonants {B, C, D, F, G, H, J, K, L, M, N, P, Q, R, S, T, V, W, X, Y, Z}
const ConsonantsCapitalized: Array[String] = ["B", "C", "D", "F", "G", "H", "J", "K", "L", "M", "N", "P", "Q", "R", "S", "T", "V", "W", "X", "Y", "Z"]
const ConsonantsLowercase: Array[String] = ["b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "w", "x", "y", "z"]

enum Vowels {A, E, I, O, U, Y, W}
const VowelsCapitalized: Array[String] = ["A", "E", "I", "O", "U", "Y", "W"]
const VowelsLowercase: Array[String] = ["a", "e", "i", "o", "u", "y", "w"]

enum NonSpecialVowels {A, E, I, O, U}
const NonSpecialVowelsCapitalized: Array[String] = ["A", "E", "I", "O", "U"]
const NonSpecialVowelsLowercase: Array[String] = ["a", "e", "i", "o", "u"]

enum SpecialVowels {Y, W}
const SpecialVowelsCapitalized: Array[String] = ["Y", "W"]
const SpecialVowelsLowercase: Array[String] = ["y", "w"]

enum SilentLetters {H}
const SilentLettersCapitalized: Array[String] = ["H"]
const SilentLettersLowercase: Array[String] = ["h"]


static func letter(index:int, capital:bool=true, type:LetterTypes=LetterTypes.Any, allow_special_vowels:bool=true) -> String:
	match type:
		LetterTypes.Any:
			if capital: return LettersCaptialized.get(index)
			else: return LettersLowercase.get(index)
		LetterTypes.Consonant:
			if capital: return ConsonantsCapitalized.get(index)
			else: return ConsonantsLowercase.get(index)
		LetterTypes.Vowel:
			if allow_special_vowels:
				if capital: return VowelsCapitalized.get(index)
				else: return VowelsLowercase.get(index)
			else:
				if capital: return NonSpecialVowelsCapitalized.get(index)
				else: return SpecialVowelsLowercase.get(index)
		LetterTypes.SpecialVowel:
			if capital: return SpecialVowelsCapitalized.get(index)
			else: return SpecialVowelsLowercase.get(index)
		LetterTypes.Silent:
			if capital: return SilentLettersCapitalized.get(index)
			else: return SilentLettersLowercase.get(index)
	return ""
