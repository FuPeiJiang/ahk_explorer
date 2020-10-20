p(oArray="", params*)
{
    if (params.Length()) {
        if (IsObject(oArray))
            finalStr:=array_tostring(oArray)
        else
            finalStr:=oArray
        for k, v in params {
            if IsObject(v)
            {
                if IsArray(v)
                    finalStr.=" [" array_tostring(v) "]"
                else
                    finalStr.=" {" array_tostring(v) "}"
            }
            Else
                finalStr.=" " v
        }
        msgbox % finalStr
        return
    }
    
    if IsObject(oArray)
    {
        if IsArray(oArray)
            msgbox % "[" Array_Print(oArray) "]"
        else
            msgbox % "{" ObjectPrint(oArray) "}"
    }
    Else
        msgbox % oArray
}

