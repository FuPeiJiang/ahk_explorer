; https://stackoverflow.com/questions/653157/a-better-similarity-ranking-algorithm-for-variable-length-strings/6859596#653165
; https://web.archive.org/web/20210415112545/http://www.catalysoft.com/articles/strikeamatch.html

; The basis of the algorithm is the method that computes the pairs of characters contained in the input string. This method creates an
; array of Strings to contain its result. It then iterates through the input string, to extract character pairs and store them in the array.
; Finally, the array is returned.

; @return an array of adjacent letter pairs contained in the input string
;    private static String[] letterPairs(String str) {
letterPairs(str) {
    pairs := []
    loop % StrLen(str) - 1 {
        pairs.push(SubStr(str, A_Index, 2))
    }
    return pairs
}

; Taking Account of White Space
; This method uses the split() method of the String class to split the input string into separate words, or tokens. It then iterates through
; each of the words, computing the character pairs for each word. The character pairs are added to an ArrayList, which is returned
; from the method. An ArrayList is used, rather than an array, because we do not know in advance how many character pairs will be
; returned. (At this point, the program doesn't know how much white space the input string contains.)

; @return an ArrayList of 2-character Strings.
;    private static ArrayList wordLetterPairs(String str) {
wordLetterPairs(str) {
    allPairs := []
    ; Tokenize the string and put the tokens/words into an array
    words := StrSplit(str, [" ", "-", "_", "."])
    ; For each word
    for unused, v in words {
        ; Find the pairs of characters
        if (v) { ;this "if" adds nothing to it
            pairsInWord := letterPairs(v)
            allPairs.push(pairsInWord*)
        }
    }
    return allPairs
}

; Computing the Metric
; This public method computes the character pairs from the words of each of the two input strings, then iterates through the ArrayLists
; to find the size of the intersection. Note that whenever a match is found, that character pair is removed from the second array list to
; prevent us from matching against the same character pair multiple times. (Otherwise, 'GGGGG' would score a perfect match against 'GG'.)
; @return lexical similarity value in the range [0,1]
; public static double compareStrings(String str1, String str2) {
stringSimilarity(str1, str2) {
    StringUpper, str1, str1
    StringUpper, str2, str2

    pairs1 := wordLetterPairs(str1)
    pairs2 := wordLetterPairs(str2)
    intersection := 0
    union := pairs1.Length() + pairs2.Length()
    for k, pair1 in pairs1 {
        for i, pair2 in pairs2 {
            if (pair1 == pair2) {
                intersection++
                pairs2.removeAt(i)
                break
            }
        }
    }
    return (2.0*intersection)/union
}
