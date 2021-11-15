p(params*) {
    finalStr:=""
    if (params.Length() > 0) {
        finalStr.=Array_p(params[1])

        k:=2, lenPlusOne:=params.Length() + 1
        while (k < lenPlusOne) {
            finalStr.=" " Array_p(params[k])
            k++
        }
    }
    MsgBox % finalStr
}
