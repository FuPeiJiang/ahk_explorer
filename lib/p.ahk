p(oArray="")
{
    
    if IsObject(oArray)
    {
        if IsArray(oArray)
            msgbox % Array_Print(oArray)
        else
            msgbox % ObjectPrint(oArray)
    }
    Else
        msgbox % oArray
}

