let
  Источник = Table.Combine(
    {
      #"(факты) Продажи подробно по дням (все)", 
      fact_addition_retail_stock_extendet_weekly, 
      fact_stock_extendet_weekly, 
      #"custom_current_shepping_list_by_seasons (for stock_sales)"
    }
  ), 
  #"Строки с примененным фильтром1" = Table.SelectRows(
    Источник, 
    each if [TypeFact] = "Продано" then [Date] >= 1 or [Date] >= 1 else true
  ), 
  #"Замененное значение" = Table.ReplaceValue(
    #"Строки с примененным фильтром1", 
    "Доступный", 
    "Остаток", 
    Replacer.ReplaceText, 
    {"TypeFact"}
  ), 
  #"Переименованные столбцы" = Table.RenameColumns(
    #"Замененное значение", 
    {
      {"Count", "QuantityFact"}, 
      {"TypeFact", "Тип факта"}, 
      {"TypePrice", "ВидЦены"}, 
      {"TypeStock", "Тип стока"}, 
      {"PeriodCompare", "Период сравнения"}, 
      {"AmountBaseEur", "AmountFactBaseEur"}, 
      {"AmountBaseRubNotDiscount", "AmountFactBaseRubNotDiscount"}, 
      {"AmountBaseRub", "AmountFactBaseRub"}, 
      {"AmountNetPriceEur", "AmountFactNetPriceEur"}, 
      {"SdID", "ПодразделениеКодУд"}, 
      {"WhID", "СкладКод"}
    }
  ), 
  #"Переупорядоченные столбцы" = Table.ReorderColumns(
    #"Переименованные столбцы", 
    {
      "Date", 
      "Тип факта", 
      "Тип стока", 
      "QuantityFact", 
      "AmountFactNetPriceEur", 
      "ВидЦены", 
      "AmountFactBaseEur", 
      "AmountFactBaseRub", 
      "AmountFactBaseRubNotDiscount", 
      "GrID", 
      "ПодразделениеКодУд", 
      "СкладКод", 
      "Период сравнения"
    }
  ), 
  #"Объединенные запросы" = Table.NestedJoin(
    #"Переупорядоченные столбцы", 
    {"СкладКод"}, 
    #"(измер) Склады", 
    {"СкладКод"}, 
    "(измер) Склады", 
    JoinKind.LeftOuter
  ), 
  #"Развернутый элемент (измер) Склады" = Table.ExpandTableColumn(
    #"Объединенные запросы", 
    "(измер) Склады", 
    {"ПодразделениеКод"}, 
    {"(измер) Склады.ПодразделениеКод"}
  ), 
  #"Добавлен пользовательский объект" = Table.AddColumn(
    #"Развернутый элемент (измер) Склады", 
    "ПодразделениеКод", 
    each 
      if [ПодразделениеКодУд] = null then
        [#"(измер) Склады.ПодразделениеКод"]
      else
        [ПодразделениеКодУд]
  ), 
  #"Измененный тип" = Table.TransformColumnTypes(
    #"Добавлен пользовательский объект", 
    {{"ПодразделениеКод", type text}}
  ), 
  #"Удаленные столбцы" = Table.RemoveColumns(#"Измененный тип", {"ПодразделениеКодУд"}), 
  #"Переупорядоченные столбцы3" = Table.ReorderColumns(
    #"Удаленные столбцы", 
    {
      "Date", 
      "Тип факта", 
      "Тип стока", 
      "QuantityFact", 
      "AmountFactNetPriceEur", 
      "ВидЦены", 
      "AmountFactBaseEur", 
      "AmountFactBaseRub", 
      "AmountFactBaseRubNotDiscount", 
      "GrID", 
      "СкладКод", 
      "ПодразделениеКод", 
      "Период сравнения"
    }
  ), 
  #"Переименованные столбцы2" = Table.RenameColumns(
    #"Переупорядоченные столбцы3", 
    {
      {"ВидЦены", "Вид цены"}, 
      {"QuantityFact", "Quantity"}, 
      {"AmountFactBaseEur", "AmountBaseEur"}, 
      {"AmountFactBaseRub", "AmountBaseRub"}, 
      {"AmountFactBaseRubNotDiscount", "AmountBaseRubNotDiscount"}, 
      {"AmountFactNetPriceEur", "AmountNetPriceEur"}
    }
  ), 
  #"Объединенные запросы3" = Table.NestedJoin(
    #"Переименованные столбцы2", 
    {"GrID"}, 
    #"(измер) Товары", 
    {"GrID"}, 
    "(измер) Товары", 
    JoinKind.LeftOuter
  ), 
  #"Развернутый элемент (измер) Товары" = Table.ExpandTableColumn(
    #"Объединенные запросы3", 
    "(измер) Товары", 
    {"Торговая марка (бренд)", "Пол"}, 
    {"(измер) Товары.Торговая марка (бренд)", "(измер) Товары.Пол"}
  ), 
  #"Объединенные запросы4" = Table.NestedJoin(
    #"Развернутый элемент (измер) Товары", 
    {"ПодразделениеКод"}, 
    #"(измер) Подразделения", 
    {"ПодразделениеКод"}, 
    "(измер) Подразделения", 
    JoinKind.LeftOuter
  ), 
  #"Развернутый элемент (измер) Подразделения" = Table.ExpandTableColumn(
    #"Объединенные запросы4", 
    "(измер) Подразделения", 
    {"TypeRelations"}, 
    {"(измер) Подразделения.TypeRelations"}
  ), 
  #"Добавлен пользовательский объект1" = Table.AddColumn(
    #"Развернутый элемент (измер) Подразделения", 
    "Пользовательский", 
    each 
      if [#"(измер) Подразделения.TypeRelations"] = "SdID|Sex" then
        [ПодразделениеКод] & [#"(измер) Товары.Пол"]
      else
        [ПодразделениеКод]
  ), 
  #"Переименованные столбцы3" = Table.RenameColumns(
    #"Добавлен пользовательский объект1", 
    {{"Пользовательский", "KeyRelationSdiv"}}
  ), 
  #"Удаленные столбцы1" = Table.RemoveColumns(
    #"Переименованные столбцы3", 
    {
      "(измер) Товары.Торговая марка (бренд)", 
      "(измер) Товары.Пол", 
      "(измер) Подразделения.TypeRelations"
    }
  ), 
  #"Измененный тип1" = Table.TransformColumnTypes(
    #"Удаленные столбцы1", 
    {{"KeyRelationSdiv", type text}}
  ), 
  #"Добавлен пользовательский объект2" = Table.AddColumn(
    #"Измененный тип1", 
    "DiscountStr", 
    each ([AmountBaseRubNotDiscount] - [AmountBaseRub]) / [AmountBaseRubNotDiscount] * 100
  ), 
  #"Вставлено: округление" = Table.AddColumn(
    #"Добавлен пользовательский объект2", 
    "Округление", 
    each Number.Round([DiscountStr], 0), 
    type number
  ), 
  #"Удаленные столбцы2" = Table.RemoveColumns(#"Вставлено: округление", {"DiscountStr"}), 
  #"Измененный тип2" = Table.TransformColumnTypes(
    #"Удаленные столбцы2", 
    {{"Округление", type text}}
  ), 
  #"Замененное значение1" = Table.ReplaceValue(
    #"Измененный тип2", 
    null, 
    "0", 
    Replacer.ReplaceValue, 
    {"Округление"}
  ), 
  #"Переименованные столбцы4" = Table.RenameColumns(
    #"Замененное значение1", 
    {{"Округление", "DiscountStr"}}
  ), 
  #"Добавлен пользовательский объект3" = Table.AddColumn(
    #"Переименованные столбцы4", 
    "MarkUpStr", 
    each ([AmountBaseEur] - [AmountNetPriceEur]) / [AmountNetPriceEur] + 1
  ), 
  #"Вставлено: округление1" = Table.AddColumn(
    #"Добавлен пользовательский объект3", 
    "Округление", 
    each Number.Round([MarkUpStr], 0), 
    type number
  ), 
  #"Удаленные столбцы3" = Table.RemoveColumns(#"Вставлено: округление1", {"MarkUpStr"}), 
  #"Измененный тип3" = Table.TransformColumnTypes(
    #"Удаленные столбцы3", 
    {{"Округление", type text}}
  ), 
  #"Переименованные столбцы5" = Table.RenameColumns(
    #"Измененный тип3", 
    {{"Округление", "MarkUpStr"}}
  ), 
  #"Строки с примененным фильтром" = Table.SelectRows(
    #"Переименованные столбцы5", 
    each ([Тип факта] = "Продано")
  )
in
  #"Строки с примененным фильтром"