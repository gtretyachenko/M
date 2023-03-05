(Date, Method) => let
    Источник = 
    if Date = null then 
        if Method =null then 
            if Date.Month(DateTime.LocalNow()) >= 9 
            or Date.Month(DateTime.LocalNow()) < 3 then
                "AW" 
            else 
                "SS" 
        else 
            if Method = "SDS" then
                if Date.Month(DateTime.LocalNow()) >= 9 then 
                    #date(Date.Year(DateTime.LocalNow()),9,1)
                else 
                    if Date.Month(DateTime.LocalNow()) < 3 then 
                        #date(Date.Year(Date.AddYears(DateTime.LocalNow(), -1)),9,1)
                    else 
                        #date(Date.Year(DateTime.LocalNow()),3,1)
            else
                ""
    else
        if Method =null then 
            if Date.Month(Date) >= 9 
            or Date.Month(Date) < 3 then
                "AW" 
            else 
                "SS" 
        else 
            if Method = "SDS" then
                if Date.Month(Date) >= 9 then 
                    #date(Date.Year(Date),9,1)
                else 
                    if Date.Month(Date) < 3 then 
                        #date(Date.Year(Date.AddYears(Date, -1)),9,1)
                    else 
                        #date(Date.Year(Date),3,1)
            else
                ""          

in
    Источник