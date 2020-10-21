string_Replicate( Str, Count ) { ; By SKAN / CD: 01-July-2017 | goo.gl/U84K7J
Return StrReplace( Format( "{:0" Count "}", "" ), 0, Str )
}

string_Multiply( Str, Count ) { ; By SKAN / CD: 01-July-2017 | goo.gl/U84K7J
Return StrReplace( Format( "{:0" Count "}", "" ), 0, Str )
}