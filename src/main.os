///////////////////////////////////////////////////////////////////
//
// Рекомендованная структура модуля точки входа приложения
//
///////////////////////////////////////////////////////////////////

#Использовать cmdline
#Использовать logos
#Использовать 1commands

#Использовать "."

///////////////////////////////////////////////////////////////////

Перем Лог;

///////////////////////////////////////////////////////////////////

Процедура Инициализация()
	Лог = Логирование.ПолучитьЛог(ПараметрыСистемы.ИмяЛогаСистемы());
	
	СистемнаяИнформация = Новый СистемнаяИнформация;
	ЭтоWindows = Найти(ВРег(СистемнаяИнформация.ВерсияОС), "WINDOWS") > 0;

	КаталогЛогов = ПолучитьКаталогЛогов();
	ИнициализироватьЛоги(КаталогЛогов);

	МенеджерКомандПриложения.РегистраторКоманд(ПараметрыСистемы);
	
КонецПроцедуры

Функция ПолучитьКаталогЛогов()
	Перем КаталогЛогов;
	Попытка 
		 КаталогЛогов = СокрЛП(ОбщиеМетоды.ЗапуститьПроцесс("git rev-parse --show-toplevel"));
	Исключение
		КаталогЛогов = ВременныеФайлы.НовоеИмяФайла(ПараметрыСистемы.ИмяПродукта());
		СоздатьКаталог(КаталогЛогов);
	КонецПопытки;  
	Возврат КаталогЛогов;
КонецФункции

Процедура ИнициализироватьЛоги(Знач КаталогЛогов)

	УровеньЛога = Лог.Уровень(); // учитываю возможность внешней настройки лога

	СИ = Новый СистемнаяИнформация;
	РежимРаботы = СИ.ПолучитьПеременнуюСреды("RUNNER_ENV");
	Если ЗначениеЗаполнено(РежимРаботы) И НРег(РежимРаботы) = "debug" Тогда
		УровеньЛога = УровниЛога.Отладка;
		Лог.УстановитьУровень(УровеньЛога);
	КонецЕсли;

	Лог.Закрыть(); // для исключения двойного вывода сообщений, например, в случае повторного вызова команд
	Если УровеньЛога = УровниЛога.Отладка Тогда
		Аппендер = Новый ВыводЛогаВФайл();
		ИмяВременногоФайла = ОбщиеМетоды.ПолучитьИмяВременногоФайлаВКаталоге(КаталогЛогов, СтрШаблон("%1.log", ПараметрыСистемы.ИмяПродукта()));
		Аппендер.ОткрытьФайл(ИмяВременногоФайла);
		Лог.ДобавитьСпособВывода(Аппендер);
	КонецЕсли;
	
	Лог.УстановитьРаскладку(ЭтотОбъект);
	
	ВыводПоУмолчанию = Новый ВыводЛогаВКонсоль();
	Лог.ДобавитьСпособВывода(ВыводПоУмолчанию);

	Лог_cmdline = Логирование.ПолучитьЛог("oscript.lib.cmdline");
	Лог_v8runner = Логирование.ПолучитьЛог("oscript.lib.v8runner");
	
	ВыводПоУмолчанию = Новый ВыводЛогаВКонсоль();
	Лог_cmdline.ДобавитьСпособВывода(ВыводПоУмолчанию);
	Лог_v8runner.ДобавитьСпособВывода(ВыводПоУмолчанию);
	
	Если УровеньЛога = УровниЛога.Отладка Тогда
		Аппендер = Новый ВыводЛогаВФайл();
		ИмяВременногоФайла = ОбщиеМетоды.ПолучитьИмяВременногоФайлаВКаталоге(КаталогЛогов, 
						СтрШаблон("%1.cmdline.log", ПараметрыСистемы.ИмяПродукта()));
		Аппендер.ОткрытьФайл(ИмяВременногоФайла);
		Лог_cmdline.ДобавитьСпособВывода(Аппендер);	
	КонецЕсли;
	
	Лог_cmdline.УстановитьУровень(УровеньЛога);
	Лог_cmdline.УстановитьРаскладку(ЭтотОбъект);
	Лог_v8runner.УстановитьУровень(УровеньЛога);
	Лог_v8runner.УстановитьРаскладку(ЭтотОбъект);
КонецПроцедуры

Функция СоответствиеПеременныхОкруженияПараметрамКоманд()	
	СоответствиеПеременных = Новый Соответствие();

	СоответствиеПеременных.Вставить("RUNNER_IBNAME", "--ibname");
	СоответствиеПеременных.Вставить("RUNNER_DBUSER", "--db-user");
	СоответствиеПеременных.Вставить("RUNNER_DBPWD", "--db-pwd");
	СоответствиеПеременных.Вставить("RUNNER_v8version", "--v8version");
	СоответствиеПеременных.Вставить("RUNNER_uccode", "--uccode");
	СоответствиеПеременных.Вставить("RUNNER_command", "--command");
	СоответствиеПеременных.Вставить("RUNNER_execute", "--execute");
	СоответствиеПеременных.Вставить("RUNNER_storage-user", "--storage-user");
	СоответствиеПеременных.Вставить("RUNNER_storage-pwd", "--storage-pwd");
	СоответствиеПеременных.Вставить("RUNNER_storage-ver", "--storage-ver");
	СоответствиеПеременных.Вставить("RUNNER_storage-name", "--storage-name");
	СоответствиеПеременных.Вставить("RUNNER_ROOT", "--root");
	СоответствиеПеременных.Вставить("RUNNER_WORKSPACE", "--workspace");
	СоответствиеПеременных.Вставить("RUNNER_PATHVANESSA", "--pathvanessa");
	СоответствиеПеременных.Вставить("RUNNER_PATHXUNIT", "--pathxunit");
	СоответствиеПеременных.Вставить("RUNNER_VANESSASETTINGS", "--vanessasettings");
	
	Возврат Новый ФиксированноеСоответствие(СоответствиеПеременных);
КонецФункции

Процедура ДополнитьАргументыИзПеременныхОкружения(Знач СоответствиеПеременных, ЗначенияПараметров)
	
	СИ = Новый СистемнаяИнформация;
	Для каждого Элемент Из СоответствиеПеременных Цикл
		ЗначениеПеременной = СИ.ПолучитьПеременнуюСреды(ВРег(Элемент.Ключ));
		ПараметрКоманднойСтроки = ЗначенияПараметров.Получить(Элемент.Значение);
		Если ПараметрКоманднойСтроки = Неопределено ИЛИ ПустаяСтрока(ПараметрКоманднойСтроки) Тогда 
			Если ЗначениеЗаполнено(ЗначениеПеременной) И НЕ ПустаяСтрока(ЗначениеПеременной) Тогда
				ЗначенияПараметров.Вставить(Элемент.Значение, ЗначениеПеременной);
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	Для Каждого Параметр Из ЗначенияПараметров Цикл
		Лог.Отладка("Передан параметр: %1 = %2", Параметр.Ключ, Параметр.Значение);
	КонецЦикла;
	
КонецПроцедуры

Функция УстановитьКаталогТекущегоПроекта(Знач Путь)
	Рез = "";
	Если ПустаяСтрока(Путь) Тогда
		Попытка
			Команда = Новый Команда;
			Команда.УстановитьСтрокуЗапуска("git rev-parse --show-toplevel");
			Команда.УстановитьПравильныйКодВозврата(0);
			Команда.Исполнить();
			Рез = СокрЛП(Команда.ПолучитьВывод());
			// Рез = СокрЛП(ЗапуститьПроцесс("git rev-parse --show-toplevel"));
		Исключение
		КонецПопытки;
	Иначе
		Рез = Путь;
	КонецЕсли;
	Возврат Рез;
КонецФункции // УстановитьКаталогТекущегоПроекта()

Функция ПолучитьПарсерКоманднойСтроки()
	
	Парсер = Новый ПарсерАргументовКоманднойСтроки();    
	МенеджерКомандПриложения.ЗарегистрироватьКоманды(Парсер);

	ЗарегистрироватьОбщиеПараметрыКоманд(Парсер);
	
	Возврат Парсер;
	
КонецФункции // ПолучитьПарсерКоманднойСтроки

Функция ВыполнениеКоманды()
	
	ПараметрыЗапуска = РазобратьАргументыКоманднойСтроки();
	
	Если ПараметрыЗапуска = Неопределено ИЛИ ПараметрыЗапуска.Количество() = 0 Тогда
		
		ВывестиВерсию();
		Лог.Ошибка("Некорректные аргументы командной строки");
		МенеджерКомандПриложения.ПоказатьСправкуПоКомандам();
		Возврат МенеджерКомандПриложения.РезультатыКоманд().ОшибкаВремениВыполнения;
		
	КонецЕсли;
	
	Команда = "";
	ЗначенияПараметров = Неопределено;
	
	Если ТипЗнч(ПараметрыЗапуска) = Тип("Структура") Тогда
		
		// это команда
		Команда				= ПараметрыЗапуска.Команда;
		ЗначенияПараметров	= ПараметрыЗапуска.ЗначенияПараметров;

		Лог.Отладка("Выполняю команду продукта %1", Команда);
		
	ИначеЕсли ЗначениеЗаполнено(ПараметрыСистемы.ИмяКомандыПоУмолчанию()) Тогда
		
		// это команда по-умолчанию
		Команда				= ПараметрыСистемы.ИмяКомандыПоУмолчанию();
		ЗначенияПараметров	= ПараметрыЗапуска;

		Лог.Отладка("Выполняю команду продукта по умолчанию %1", Команда);
		
	Иначе
		
		ВызватьИсключение "Некорректно настроено имя команды по-умолчанию.";
		
	КонецЕсли;
	
	Если Команда <> ПараметрыСистемы.ИмяКомандыВерсия() Тогда
		ВывестиВерсию();
	КонецЕсли;

	СоответствиеПеременных = СоответствиеПеременныхОкруженияПараметрамКоманд();
			
	ДополнитьАргументыИзПеременныхОкружения(СоответствиеПеременных, ЗначенияПараметров);
	
	ПараметрыСистемы.КорневойПутьПроекта = УстановитьКаталогТекущегоПроекта(ЗначенияПараметров["--root"]);

	Возврат МенеджерКомандПриложения.ВыполнитьКоманду(Команда, ЗначенияПараметров);
	
КонецФункции // ВыполнениеКоманды()

Процедура ЗарегистрироватьОбщиеПараметрыКоманд(Парсер)
	Парсер.ДобавитьИменованныйПараметр("--ibname", "Строка подключения к БД", Истина);
	Парсер.ДобавитьИменованныйПараметр("--db-user", "Пользователь БД", Истина);
	Парсер.ДобавитьИменованныйПараметр("--db-pwd", "Пароль БД", Истина);
	Парсер.ДобавитьИменованныйПараметр("--v8version", "Версия платформы", Истина);
	Парсер.ДобавитьИменованныйПараметр("--root", "Полный путь к проекту", Истина);
	Парсер.ДобавитьИменованныйПараметр("--ordinaryapp", "Запуск толстого клиента (1 = толстый, 0 = тонкий клиент)", Истина);
	Парсер.ДобавитьИменованныйПараметр("--settings", "Путь к файлу настроек, в формате json", Истина);
КонецПроцедуры

Процедура ВывестиВерсию()
	
	Сообщить(СтрШаблон("%1 v%2", ПараметрыСистемы.ИмяПродукта(), ПараметрыСистемы.ВерсияПродукта()));
	
КонецПроцедуры // ВывестиВерсию()

Функция РазобратьАргументыКоманднойСтроки()
	
	Парсер = ПолучитьПарсерКоманднойСтроки();
	Возврат Парсер.Разобрать(АргументыКоманднойСтроки);
	
КонецФункции // РазобратьАргументыКоманднойСтроки

Функция Форматировать(Знач Уровень, Знач Сообщение) Экспорт

	Возврат СтрШаблон("%1: %2 - %3", ТекущаяДата(), УровниЛога.НаименованиеУровня(Уровень), Сообщение);

КонецФункции

///////////////////////////////////////////////////////////////////

Инициализация();

Попытка
		
	ЗавершитьРаботу(ВыполнениеКоманды());
	ВременныеФайлы.Удалить();
		
Исключение
		
	Лог.КритичнаяОшибка(ОписаниеОшибки());
	ВременныеФайлы.Удалить();

	ЗавершитьРаботу(МенеджерКомандПриложения.РезультатыКоманд().ОшибкаВремениВыполнения);
		
КонецПопытки;
