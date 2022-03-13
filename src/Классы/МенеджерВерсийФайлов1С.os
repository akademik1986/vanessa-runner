#Использовать logos
#Использовать v8runner
#Использовать fs
#Использовать json
#Использовать v8unpack

#Область ОписаниеПеременных

Перем Лог;

#КонецОбласти

#Область ПрограммныйИнтерфейс

Функция ВерсияКонфигурации(Знач ПутьФайлаКонфигурации) Экспорт

	//ИмяФайлаКонфигурации = ИмяФайлаКонфигурации(КаталогИсходников);
	Лог.Отладка("читаю версию из исходников конфигурации %1", ПутьФайлаКонфигурации);

	СтрокаXML = ПрочитатьФайл(ПутьФайлаКонфигурации);
	Результат = ВерсияКонфигурацииПоХМЛ(СтрокаXML);

	Возврат Результат;

КонецФункции

Функция УстановитьВерсиюКонфигурации(Знач ПутьФайлаКонфигурации, Знач НовыйНомерВерсии) Экспорт

	Возврат ЗаписатьНомерВерсии(ПутьФайлаКонфигурации, НовыйНомерВерсии);

КонецФункции

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ПрочитатьФайл(Знач ПутьФайлаКонфигурации)

	//ИмяФайлаКонфигурации = ИмяФайлаКонфигурации(КаталогИсходников);

	ТекстовыйДокумент = Новый ТекстовыйДокумент();
	ТекстовыйДокумент.Прочитать(ПутьФайлаКонфигурации, КодировкаТекста.UTF8);
	Возврат ТекстовыйДокумент.ПолучитьТекст();

КонецФункции

Функция ВерсияКонфигурацииПоХМЛ(Знач ХМЛСтрокаФайлаКонфигурации)

	РегулярноеВыражение = Новый РегулярноеВыражение("<Version>(\d+.\d+.\d+.\d+)<\/Version>");
	Совпадения = РегулярноеВыражение.НайтиСовпадения(ХМЛСтрокаФайлаКонфигурации);
	Если Совпадения.Количество() = 0 Тогда
		ВызватьИсключение "Версия проекта не определена";
	КонецЕсли;

	Результат = Совпадения[0].Группы[1].Значение;

	Лог.Отладка("текущая версия %1", Результат);

	Возврат Результат;

КонецФункции

Функция ЗаписатьНомерВерсии(ПутьФайлаКонфигурации, НомерВерсии)

	//ИмяФайлаКонфигурации = ИмяФайлаКонфигурации(КаталогИсходников);

	Лог.Отладка("устанавливаю версию %1 в исходниках конфигурации %2", НомерВерсии, ПутьФайлаКонфигурации);
	СтрокаXML = ПрочитатьФайл(ПутьФайлаКонфигурации);

	Результат = ВерсияКонфигурацииПоХМЛ(СтрокаXML);

	ШаблонПодстановки = СтрШаблон("<Version>%1</Version>", НомерВерсии);
	РегулярноеВыражение = Новый РегулярноеВыражение("(<Version>\d+.\d+.\d+.\d+<\/Version>)");
	НоваяСтрокаXML = РегулярноеВыражение.Заменить(СтрокаXML, ШаблонПодстановки);

	ТекстовыйДокумент = Новый ТекстовыйДокумент();
	ТекстовыйДокумент.УстановитьТекст(НоваяСтрокаXML);
	ТекстовыйДокумент.Записать(ПутьФайлаКонфигурации, КодировкаТекста.UTF8);

	Возврат Результат;

КонецФункции

Функция ВерсияСоСборкой(Знач НомерВерсии, Знач НомерСборки)

	ШаблонПодстановки = СтрШаблон("$1.%1", НомерСборки);
	РегулярноеВыражение = Новый РегулярноеВыражение("(\d+.\d+.\d+).(\d+)");
	Возврат РегулярноеВыражение.Заменить(НомерВерсии, ШаблонПодстановки);

КонецФункции

Функция ПутьФайлаКонфигурации(Знач КаталогИсходников)
	Возврат ОбъединитьПути(КаталогИсходников, "Configuration.xml");
КонецФункции

Функция ПолучитьЛог()
	Если Лог = Неопределено Тогда
		Лог = Логирование.ПолучитьЛог(ПараметрыСистемы.ИмяЛогаСистемы());
	КонецЕсли;
	Возврат Лог;
КонецФункции

#КонецОбласти

ПолучитьЛог();
