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
; public static double compareStrings(String hayStack, String searchString) {
howMuchOf_searchString_isFound(hayStack, searchString) {
    StringUpper, hayStack, hayStack
    StringUpper, searchString, searchString

    hayStack_pairs := wordLetterPairs(hayStack)
    searchString_pairs := wordLetterPairs(searchString)
    intersection := 0
    union := searchString_pairs.Length()
    for k, pair1 in hayStack_pairs {
        for i, pair2 in searchString_pairs {
            if (pair1 == pair2) {
                intersection++
                searchString_pairs.removeAt(i)
                break
            }
        }
    }
    return intersection/union
}


orderMatters(hayStack, searchString) {
    StringUpper, hayStack, hayStack
    StringUpper, searchString, searchString

    hayStack_pairs := wordLetterPairs(hayStack)
    searchString_pairs := wordLetterPairs(searchString)
    intersection := 0
    union := searchString_pairs.Length()

    startingI := 1
    searchString_pairs_Len := searchString_pairs.Length() + 1
    for k, pair1 in hayStack_pairs {
        i:=startingI
        while (i < searchString_pairs_Len) {
            if (pair1 == searchString_pairs[i]) {
                intersection++
                startingI:=i + 1
                break
            }
            i++
        }
    }
    return intersection/union
}

orderAndProximity_Matter(hayStack, searchString) {
    StringUpper, hayStack, hayStack
    StringUpper, searchString, searchString

    hayStack_pairs := wordLetterPairs(hayStack)
    searchString_pairs := wordLetterPairs(searchString)
    intersection := 0
    union := searchString_pairs.Length()

    startingI := 1
    searchString_pairs_Len := searchString_pairs.Length() + 1
    for k, pair1 in hayStack_pairs {
        i:=startingI
        while (i < searchString_pairs_Len) {
            if (pair1 == searchString_pairs[i]) {

                if (lastFound_hayStack_pairsIdx) {
                    intersection+=1/(k - lastFound_hayStack_pairsIdx)
                } else {
                    intersection++
                }

                startingI:=i + 1
                lastFound_hayStack_pairsIdx := k
                break
            }
            i++
        }
    }
    return intersection/union
}

orderAndProximity_Matter_WithReversed(hayStack, searchString) {
    StringUpper, hayStack, hayStack
    StringUpper, searchString, searchString

    hayStack_pairs := wordLetterPairs(hayStack)
    searchString_pairs := wordLetterPairs(searchString)
    intersection := 0
    union := searchString_pairs.Length()

    startingI := 1
    searchString_pairs_Len := searchString_pairs.Length() + 1
    for k, pair1 in hayStack_pairs {
        i:=startingI
        while (i < searchString_pairs_Len) {
            if (pair1 == searchString_pairs[i]) {

                if (lastFound_hayStack_pairsIdx) {
                    intersection+=1/(k - lastFound_hayStack_pairsIdx)
                } else {
                    intersection++
                }

                startingI:=i + 1
                lastFound_hayStack_pairsIdx := k
                break
            } else if (pair1 == FlipStr(searchString_pairs[i])) {

                if (lastFound_hayStack_pairsIdx) {
                    intersection+=0.5/(k - lastFound_hayStack_pairsIdx)
                } else {
                    intersection++
                }

                startingI:=i + 1
                lastFound_hayStack_pairsIdx := k

                break
            }
            i++
        }
    }
    return intersection/union
}

FlipStr(Str) { ;https://www.autohotkey.com/board/topic/42396-fastest-way-to-reverse-a-string/#post_id_264725
    ; static _strrev_Proc := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "msvcrt", "Ptr"), "AStr", "_strrev", "Ptr")
    static _wcsrev_Proc := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "msvcrt", "Ptr"), "AStr", "_wcsrev", "Ptr")
    ; DllCall("msvcrt\_strrev", "UInt",&Str, "CDecl")
    ; DllCall("msvcrt\_wcsrev", "UInt",&Str, "CDecl")
    DllCall(_wcsrev_Proc, "UInt",&Str, "CDecl")
    ; https://docs.microsoft.com/en-us/cpp/c-runtime-library/reference/strrev-wcsrev-mbsrev-mbsrev-l?view=msvc-170#:~:text=_wcsrev%20and%20_mbsrev%20are%20wide%2Dcharacter
    ; we need wide char
    return Str
}
