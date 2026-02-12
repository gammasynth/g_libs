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
