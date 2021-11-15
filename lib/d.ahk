d(params*) {
    finalStr:=""
    if (params.Length() > 0) {
        finalStr.=array_d(params[1])

        k:=2, lenPlusOne:=params.Length() + 1
        while (k < lenPlusOne) {
            finalStr.="`n" array_d(params[k])
            k++
        }
    }
    Clipboard:=finalStr
    p(params*)
}
