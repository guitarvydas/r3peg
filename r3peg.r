REBOL [ Title: "PEG Parser" ]

peg: make object! [
	space: charset reduce [tab #" "]
	any-char: [1 skip]
	comment: [#"#" thru newline]
	spacing: [any [comment | space | newline]]

	dot: [#"." spacing]
	close-brace: [#"}" spacing]
	open-brace: [#"{" spacing]
	close-paren: [#")" spacing]
	open-paren: [#"(" spacing]
	plus: [#"+" spacing]
	star: [#"*" spacing]
	question: [#"?" spacing]
	pNot: [#"!" spacing]
	pAnd: [#"&" spacing]
	slash: [#"/" spacing]
	left-arrow: ["<-" spacing]

	digit: charset [#"0" - #"9"]
	digit02: charset [#"0" - #"2"]
	digit07: charset [#"0" - #"7"]
	num-char1: [#"\" digit02 digit07 digit07]
	num-char2: [#"\" digit07 [opt digit07]]

	esc-char: [#"\" [#"n" | #"r" | #"t" | #"'" | #"^"" | #"[" | #"]" | #"\"]]

	pChar: [esc-char | num-char1 | num-char2 | any-char]

	single-char: pChar

	char-range: [pChar #"-" pChar]

	range: [char-range | single-char]

	pClass: [#"[" [any not-rb] #"]"]

	not-rb: [[not #"]"] range]

	literal: [[[#"^'" [any not-single] #"^'"] | [#"^"" [any not-double] #"^""]] spacing]
	not-single: [[not #"^'"] pChar]
	not-double: [[not #"^""] pChar]

	identifier: [ident-start [any ident-cont] spacing]
	ident-start: charset [#"a" - #"z" #"A" - #"Z"]
	ident-cont: [ident-start | #"-" | digit]

	primary: [prim1 | prim2 | literal | pClass | dot]
	prim1: [identifier and [not left-arrow]]
	prim2: [open-paren expression close-paren]

	expression: [psequence any slash-sequence]
	slash-sequence: [slash psequence]
	psequence: [any prefix]
	prefix: [opt [pand | pnot] suffix]
	suffix: [ primary opt [question | star | plus] spacing]

	definition: [identifier left-arrow expression spacing opt semantic-code]
	semantic-code: [open-brace [some not-brace] close-brace]
	not-brace: [literal | [not close-brace any-char]]

	; grammar is the main entry point
	grammar: [spacing [some definition] spacing]

	test: func [] [
		do %rpeg.r
		str: read/string %test.peg
		parse str grammar
	]
]
