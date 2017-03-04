///////////////////////////////////////////////////////////////////
//
// Служебный модуль с набором методов работы с командами приложения
//
// Структура модуля реализована в соответствии с рекомендациями 
// oscript-app-template (C) EvilBeaver
//
///////////////////////////////////////////////////////////////////

#Использовать logos
#Использовать fs
#Использовать v8runner

Перем Лог;
Перем КорневойПутьПроекта;

///////////////////////////////////////////////////////////////////////////////////////////////////
// Прикладной интерфейс

Процедура ЗарегистрироватьКоманду(Знач ИмяКоманды, Знач Парсер) Экспорт

	ТекстОписания = 
		"     инициализируем пустую базу данных для выполнения необходимых тестов.
		|     указываем путь к исходниками с конфигурацией,
		|     указываем версию платформы, которую хотим использовать,
		|     и получаем по пути build\ib готовую базу для тестирования.";

	ОписаниеКоманды = Парсер.ОписаниеКоманды(ПараметрыСистемы.ВозможныеКоманды().ИнициализацияОкружения, ТекстОписания);
	
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--src", "Путь к папке исходников");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--dt", "Путь к файлу с dt выгрузкой");
	Парсер.ДобавитьПараметрФлагКоманды(ОписаниеКоманды, "--dev", "Признак dev режима, создаем и загружаем автоматом структуру конфигурации");
	Парсер.ДобавитьПараметрФлагКоманды(ОписаниеКоманды, "--storage", "Признак обновления из хранилища");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--storage-name", "Строка подключения к хранилище");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--storage-user", "Пользователь хранилища");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--storage-pwd", "Пароль");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--storage-ver",	"Номер версии, по умолчанию берем последнюю");
	Парсер.ДобавитьКоманду(ОписаниеКоманды);
	
КонецПроцедуры // ЗарегистрироватьКоманду

// Выполняет логику команды
// 
// Параметры:
//   ПараметрыКоманды - Соответствие - Соответствие ключей командной строки и их значений
//   ДополнительныеПараметры (необязательно) - Соответствие - дополнительные параметры
//
Функция ВыполнитьКоманду(Знач ПараметрыКоманды, Знач ДополнительныеПараметры = Неопределено) Экспорт

	Лог = ДополнительныеПараметры.Лог;
	КорневойПутьПроекта = ПараметрыСистемы.КорневойПутьПроекта;

	ИнициализироватьБазуДанных(ПараметрыКоманды["--src"], ПараметрыКоманды["--dt"],
					ПараметрыКоманды["--ibname"], ПараметрыКоманды["--db-user"], ПараметрыКоманды["--db-pwd"],, 
					ПараметрыКоманды["--v8version"], ПараметрыКоманды["--dev"], ПараметрыКоманды["--storage"], 
					ПараметрыКоманды["--storage-name"], ПараметрыКоманды["--storage-user"], ПараметрыКоманды["--storage-pwd"], ПараметрыКоманды["--storage-ver"]);

	Возврат МенеджерКомандПриложения.РезультатыКоманд().Успех;
КонецФункции // ВыполнитьКоманду

Процедура ИнициализироватьБазуДанных(Знач ПутьКSRC="", Знач ПутьКDT="", Знач СтрокаПодключения="", Знач Пользователь="", Знач Пароль="",
										Знач КлючРазрешенияЗапуска = "", Знач ВерсияПлатформы="", Знач РежимРазработчика = Ложь, 
										Знач РежимОбновленияХранилища = Ложь, Знач СтрокаПодключенияХранилище = "", Знач ПользовательХранилища="", Знач ПарольХранилища="",
										Знач ВерсияХранилища="") 
	Перем БазуСоздавали;
	БазуСоздавали = Ложь;                                    
	ТекущаяПроцедура = "Запускаем инициализацию";

	Конфигуратор = Новый УправлениеКонфигуратором();
	Логирование.ПолучитьЛог("oscript.lib.v8runner").УстановитьУровень(Лог.Уровень());

	Если НЕ ПустаяСтрока(ВерсияПлатформы) Тогда
		Лог.Отладка("ИнициализироватьБазуДанных ВерсияПлатформы:"+ВерсияПлатформы);
		Конфигуратор.ИспользоватьВерсиюПлатформы(ВерсияПлатформы);
	КонецЕсли;
	Конфигуратор.УстановитьИмяФайлаСообщенийПлатформы(ПолучитьИмяВременногоФайла("log"));
	СоздатьКаталог(ОбъединитьПути(КорневойПутьПроекта, "build", "out"));

	Если ПустаяСтрока(СтрокаПодключения) Тогда

		КаталогБазы = ОбъединитьПути(КорневойПутьПроекта, ?(РежимРазработчика = Истина, "./build/ibservice", "./build/ib"));
		СтрокаПодключения = "/F""" + КаталогБазы + """";
	КонецЕсли;

	Лог.Отладка("ИнициализироватьБазуДанных СтрокаПодключения:"+ВерсияПлатформы);

	Если Лев(СтрокаПодключения,2)="/F" Тогда
		КаталогБазы = ОбщиеМетоды.УбратьКавычкиВокругПути(Сред(СтрокаПодключения,3, СтрДлина(СтрокаПодключения)-2));
		ФайлБазы = Новый Файл(КаталогБазы);
		Если ФайлБазы.Существует() Тогда 
			Лог.Отладка("Удаляем файл "+ФайлБазы.ПолноеИмя);
			УдалитьФайлы(ФайлБазы.ПолноеИмя, ПолучитьМаскуВсеФайлы());
		КонецЕсли;
		СоздатьКаталог(ФайлБазы.ПолноеИмя);
		СоздатьФайловуюБазу(Конфигуратор, ФайлБазы.ПолноеИмя, ,);
		БазуСоздавали = Истина;
		Лог.Информация("Создали базу данных для " + СтрокаПодключения);
	КонецЕсли;

	Конфигуратор.УстановитьКонтекст(СтрокаПодключения, "", "");
	Если Не ПустаяСтрока(ПутьКDT) Тогда
		ПутьКDT = Новый Файл(ОбъединитьПути(КорневойПутьПроекта, ПутьКDT)).ПолноеИмя;
		Лог.Информация("Загружаем dt "+ ПутьКDT);
		Если БазуСоздавали = Истина Тогда 
			Попытка 
				Конфигуратор.ЗагрузитьИнформационнуюБазу(ПутьКDT);
			Исключение
				Лог.Ошибка("Не удалось загрузить:"+ОписаниеОшибки());
			КонецПопытки;
		Иначе
			Попытка
				Конфигуратор.УстановитьКонтекст(СтрокаПодключения, Пользователь, Пароль);
				Конфигуратор.ЗагрузитьИнформационнуюБазу(ПутьКDT);    
			Исключение
				Лог.Ошибка("Не удалось загрузить:"+ОписаниеОшибки());
			КонецПопытки;
		КонецЕсли;
	КонецЕсли;

	Конфигуратор.УстановитьКонтекст(СтрокаПодключения, Пользователь, Пароль);
	
	runner = ОбщиеМетоды.ПодключитьРаннер();

	Если Не ПустаяСтрока(ПутьКSRC) Тогда
		Лог.Информация("Запускаю загрузку конфигурации из исходников");

		ПутьКSRC = Новый Файл(ОбъединитьПути(КорневойПутьПроекта, ПутьКSRC)).ПолноеИмя;
		СписокФайлов = "";
		runner.СобратьИзИсходниковТекущуюКонфигурацию(ПутьКSRC, СтрокаПодключения, Пользователь, Пароль, ВерсияПлатформы, СписокФайлов, Ложь);
	КонецЕсли;

	Если РежимОбновленияХранилища = Истина Тогда
		Лог.Информация("Обновляем из хранилища");
		runner.ЗапуститьОбновлениеИзХранилища(СтрокаПодключения, Пользователь, Пароль, СтрокаПодключенияХранилище, ПользовательХранилища, ПарольХранилища, ВерсияХранилища, ВерсияПлатформы)
	КонецЕсли;

	Если РежимРазработчика = Ложь Тогда 
		runner.ЗапуститьОбновлениеКонфигурации(СтрокаПодключения, Пользователь, Пароль, КлючРазрешенияЗапуска, ВерсияПлатформы);
	КонецЕсли;

	Лог.Информация("Инициализация завершена");
	
КонецПроцедуры //ИнициализироватьБазуДанных

Процедура СоздатьФайловуюБазу(Конфигуратор, Знач КаталогБазы, Знач ПутьКШаблону="", Знач ИмяБазыВСписке="") //Экспорт
	Лог.Отладка("Создаю файловую базу "+КаталогБазы);

	ФС.ОбеспечитьКаталог(КаталогБазы);
	УдалитьФайлы(КаталогБазы, "*.*");

	ПараметрыЗапуска = Новый Массив;
	ПараметрыЗапуска.Добавить("CREATEINFOBASE");
	ПараметрыЗапуска.Добавить("File="""+КаталогБазы+"""");
	ПараметрыЗапуска.Добавить("/Out""" +Конфигуратор.ФайлИнформации() + """");
	ПараметрыЗапуска.Добавить("/Lru");
	
	Если ИмяБазыВСписке <> "" Тогда
		ПараметрыЗапуска.Добавить("/AddInList"""+ ИмяБазыВСписке + """");
	КонецЕсли;
	Если ПутьКШаблону<> "" Тогда
		ПараметрыЗапуска.Добавить("/UseTemplate"""+ ПутьКШаблону + """");
	КонецЕсли;

	СтрокаЗапуска = "";
	СтрокаДляЛога = "";
	Для Каждого Параметр Из ПараметрыЗапуска Цикл
		СтрокаЗапуска = СтрокаЗапуска + " " + Параметр;
		Если Лев(Параметр,2) <> "/P" и Лев(Параметр,25) <> "/ConfigurationRepositoryP" Тогда
			СтрокаДляЛога = СтрокаДляЛога + " " + Параметр;
		КонецЕсли;
	КонецЦикла;

	Приложение = "";
	Приложение = Конфигуратор.ПутьКПлатформе1С();
	Если Найти(Приложение, " ") > 0 Тогда 
		Приложение = ОбщиеМетоды.ОбернутьПутьВКавычки(Приложение);
	КонецЕсли;
	Приложение = Приложение + " "+СтрокаЗапуска;
	Попытка
		ОбщиеМетоды.ЗапуститьПроцесс(Приложение);    
	Исключение
		Сообщить(ОписаниеОшибки());
	КонецПопытки;
	РезультатСообщение = ОбщиеМетоды.ПрочитатьФайлИнформации(Конфигуратор.ФайлИнформации());
	Если СтрНайти(РезультатСообщение, "успешно завершено") = 0 Тогда
		ВызватьИсключение "Результат работы не успешен: " + Символы.ПС + РезультатСообщение; 
	КонецЕсли;


КонецПроцедуры
