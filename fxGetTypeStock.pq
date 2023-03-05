let
  Источник = (
    optional StartSeasonDate as date, 
    optional EndSeasonDate as date, 
    optional Mix3 as text, 
    optional ToDate as date
  ) =>
    if StartSeasonDate is null or EndSeasonDate is null then
      "Old+Dead" // или "no seasons"
    else if StartSeasonDate > ToDate 
    then
      "Next" // или "Next " & fxGetSeasonData(StartSeasonDate, null)
    else if List.Contains(
      List.Dates(
        StartSeasonDate, 
        Duration.Days(EndSeasonDate - StartSeasonDate), 
        #duration(1, 0, 0, 0)
      ), 
      ToDate
    )
    then
      "Current" // или "Active"
    else if List.Contains(
      List.Dates(
        StartSeasonDate, 
        Duration.Days(EndSeasonDate - StartSeasonDate), 
        #duration(1, 0, 0, 0)
      ), 
      Date.AddDays(ToDate, - 365)
    )
    then
      if List.Contains({"COS", "COW", "AS"}, Text.Upper(Mix3)) then
        "Aged " & fxGetSeasonData(StartSeasonDate, null) & " CO" // или "Active" но проверить на текущую сезонность
      else
        "Aged " & fxGetSeasonData(StartSeasonDate, null)
    else if List.Contains(
      List.Dates(
        StartSeasonDate, 
        Duration.Days(EndSeasonDate - StartSeasonDate), 
        #duration(1, 0, 0, 0)
      ), 
      Date.AddDays(ToDate, - 183)
    )
    then
      if List.Contains({"COS", "COW", "AS"}, Text.Upper(Mix3)) then
        "Aged " & fxGetSeasonData(StartSeasonDate, null) & " CO" // или "Active" но проверить на текущую сезонность
      else
        "Aged " & fxGetSeasonData(StartSeasonDate, null)
    else if Duration.Days(EndSeasonDate - StartSeasonDate) <= 3 * 365 then
      "Old+Dead" // или "Old " & fxGetSeasonData(StartSeasonDate, null)
    else if Duration.Days(EndSeasonDate - StartSeasonDate) > 3 * 365 then
      "Old+Dead" // или "Dead "  & fxGetSeasonData(StartSeasonDate, null)
    else
      "!Нет условия!"
in
  Источник 