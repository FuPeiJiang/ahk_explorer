d(arr) {
    if (IsObject(arr)) {
        clipboard:=array_ToNewLineString(arr)
    } else {
        clipboard:=arr
    }
    p(arr)
}