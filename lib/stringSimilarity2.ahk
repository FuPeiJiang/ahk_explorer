wordLetterPairs(str) {
    allPairs := []
    ; Tokenize the string and put the tokens/words into an array
    words := StrSplit(str, [" ", "-", "_", ".", "&"])

    ; For each word
    for unused, word in words {
        ; Find the pairs of characters
        loop % StrLen(word) - 1 {
            allPairs.push(SubStr(word, A_Index, 2))
        }
    }

    return allPairs
}

reverse_wordLetterPairs(str) {
    ; ne.sDY8RKA6LTh-slatnemadnuF 08.2 rednelB - mrofsnarT & tceleS
    ; eS le
    reversedPairs := []
    wordsReversed := StrSplit(flipStr(str), [" ", "-", "_", ".", "&"])
    i:=wordsReversed.Length()
    while (i > 0) {
        word:=wordsReversed[i]
        j:=StrLen(word) - 1
        while (j > 0) {
            reversedPairs.push(SubStr(word, j, 2)), j--
        }
        i--
    }

    return reversedPairs
}


orderAndProximity_Matter_WithReversed(hayStack, searchString) {
    StringUpper, hayStack, hayStack
    StringUpper, searchString, searchString

    hayStack_pairs := wordLetterPairs(hayStack)
    searchString_pairs := wordLetterPairs(searchString), reverse_searchString_pairs:=reverse_wordLetterPairs(searchString)

    intersection := 0
    union := searchString_pairs.Length()

    startingI := 1
    searchString_pairs_Len := searchString_pairs.Length() + 1
    lastFound_hayStack_pairsIdx:=false
    for k, pair1 in hayStack_pairs {
        i:=startingI
        while (i < searchString_pairs_Len) {
            if (pair1 == searchString_pairs[i]) {

                howManyPoints:=1

            } else if (pair1 == reverse_searchString_pairs[i]) {

                howManyPoints:=0.5

            } else {
                i++
                continue
            }

            if (lastFound_hayStack_pairsIdx) {
                intersection+=howManyPoints/(k - lastFound_hayStack_pairsIdx)
            } else {
                intersection++
            }

            startingI:=i + 1
            lastFound_hayStack_pairsIdx := k
            break
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
