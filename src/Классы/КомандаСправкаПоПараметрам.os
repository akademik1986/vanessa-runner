///////////////////////////////////////////////////////////////////
//
// Служебный модуль с набором методов работы с командами приложения
//
// Структура модуля реализована в соответствии с рекомендациями 
// oscript-app-template (C) EvilBeaver
//
///////////////////////////////////////////////////////////////////

Процедура ЗарегистрироватьКоманду(Знач ИмяКоманды, Знач Парсер) Экспорт

	ОписаниеКоманды = Парсер.ОписаниеКоманды(ИмяКоманды, "Вывод справки по параметрам");
	Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, "Команда");
	Парсер.ДобавитьКоманду(ОписаниеКоманды);
	
КонецПроцедуры // ЗарегистрироватьКоманду

// Выполняет логику команды
// 
// Параметры:
//   ПараметрыКоманды - Соответствие - Соответствие ключей командной строки и их значений
//   ДополнительныеПараметры (необязательно) - Соответствие - дополнительные параметры
//
Функция ВыполнитьКоманду(Знач ПараметрыКоманды, Знач Неиспользуется = Неопределено) Экспорт

	Парсер = Новый ПарсерАргументовКоманднойСтроки;

	МенеджерКомандПриложения.ЗарегистрироватьКоманды(Парсер);

	Если ПараметрыКоманды["Команда"] = Неопределено Тогда

		ПоказатьВозможныеКоманды(Парсер);

	Иначе
		
		ПоказатьСправкуПоКоманде(Парсер, ПараметрыКоманды["Команда"]);

	КонецЕсли;

	ПоказатьОбщиеПараметрыКоманд();

	Возврат МенеджерКомандПриложения.РезультатыКоманд().Успех;

КонецФункции // ВыполнитьКоманду

Процедура ПоказатьВозможныеКоманды(Знач Парсер)

	Парсер.ВывестиСправкуПоКомандам();

КонецПроцедуры // ПоказатьВозможныеКоманды

Процедура ПоказатьСправкуПоКоманде(Знач Парсер, Знач ИмяКоманды)

	Парсер.ВывестиСправкуПоКоманде(ИмяКоманды);

КонецПроцедуры // ПоказатьСправкуПоКоманде

Процедура ПоказатьОбщиеПараметрыКоманд()
	Сообщить(" ");
	Сообщить(" общие для всех параметры");
	Сообщить("       --v8version Маска версии платформы (8.3, 8.3.5, 8.3.6.2299 и т.п.)");
	Сообщить(" общие для xunit, vaness, tests, compilecurrent, decompilecurrent, run, dbupdate");
	Сообщить("       --ibname строка подключения к базе данных");
	Сообщить("       --db-user имя пользователя для подключения к базе");
	Сообщить("       --db-pwd пароль пользователя");
КонецПроцедуры