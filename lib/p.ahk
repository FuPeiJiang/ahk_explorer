p(oArray="", params*)
{
    params.Insert(1, oArray)
    for k, v in params {
        
        if (k!=1)
            space:=" "
        
        if IsObject(v)
        {
            if IsArray(v)
                finalStr.=space "[" Array_Print(v) "]"
            else
                finalStr.=space "{" ObjectPrint(v) "}"
        }
        Else
            finalStr.=space v
    }
    msgbox % finalStr
    return
}