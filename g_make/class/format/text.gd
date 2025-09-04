class_name Text

## RichText BBCode Colors
enum COLORS {black, red, green, yellow, blue, magenta, pink, purple, cyan, white, orange, gray}
const COLOR_NAMES: Array[String] = ["black", "red", "green", "yellow", "blue", "magenta", "pink", "purple", "cyan", "white", "orange", "gray"]

static func color(text:String, with_color:COLORS, centered:bool=false) -> String:
	var clr = COLOR_NAMES[with_color]
	text = str("[color=" + clr + "]" + text + "[/color]")
	if centered: return center(text)
	return text

static func center(text:String, do:bool=true) -> String:
	if not do: return text
	return str("[center]" + text + "[/center]")
