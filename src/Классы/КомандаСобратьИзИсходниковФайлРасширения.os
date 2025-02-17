///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Сборка cfe-файла из исходников
//
// TODO добавить фичи для проверки команды
//
// Служебный модуль с набором методов работы с командами приложения
//
// Структура модуля реализована в соответствии с рекомендациями
// oscript-app-template (C) EvilBeaver
//
///////////////////////////////////////////////////////////////////////////////////////////////////

#Использовать logos
#Использовать v8runner

Перем Лог;
Перем МенеджерКонфигуратора;

///////////////////////////////////////////////////////////////////////////////////////////////////
// Прикладной интерфейс

Процедура ЗарегистрироватьКоманду(Знач ИмяКоманды, Знач Парсер) Экспорт

	ТекстОписания =
		"     Сборка cfe-файла из исходников.";

	ОписаниеКоманды = Парсер.ОписаниеКоманды(ИмяКоманды,
		ТекстОписания);

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--src",
		"Путь к каталогу с исходниками, пример: --src=./cfe");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "-s",
		"Краткая команда 'путь к исходникам --src', пример: -s ./cfe");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--out", "Путь к файлу cf (*.cf), --out=./Extension.cfe");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "-o",
		"Краткая команда 'Путь к файлу cf --out', пример: -o ./Extension.cfe");
	Парсер.ДобавитьПараметрФлагКоманды(ОписаниеКоманды, "--current", "Флаг загрузки в указанную базу или -с");
	Парсер.ДобавитьПараметрФлагКоманды(ОписаниеКоманды, "-c", "Флаг загрузки в указанную базу, краткая форма от --current");

	// TODO зачем объявлен параметр "--noupdate", который в коде не используется
	Парсер.ДобавитьПараметрФлагКоманды(ОписаниеКоманды, "--noupdate", "Флаг обновления СonfigDumpInfo.xml");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--build-number",
		"Номер сборки для установки в последний разряд номера версии");

	Парсер.ДобавитьКоманду(ОписаниеКоманды);

КонецПроцедуры

// Выполняет логику команды
//
// Параметры:
//   ПараметрыКоманды - Соответствие - Соответствие ключей командной строки и их значений
//   ДополнительныеПараметры - Соответствие - дополнительные параметры (необязательно)
//
Функция ВыполнитьКоманду(Знач ПараметрыКоманды, Знач ДополнительныеПараметры = Неопределено) Экспорт

	Попытка
		Лог = ДополнительныеПараметры.Лог;
	Исключение
		Лог = Логирование.ПолучитьЛог(ПараметрыСистемы.ИмяЛогаСистемы());
	КонецПопытки;

	ДанныеПодключения = ПараметрыКоманды["ДанныеПодключения"];

	ПутьВходящий = ОбщиеМетоды.ПолныйПуть(ОбщиеМетоды.ПолучитьПараметры(ПараметрыКоманды, "-s", "--src"));
	ПутьИсходящий = ОбщиеМетоды.ПолныйПуть(ОбщиеМетоды.ПолучитьПараметры(ПараметрыКоманды,"-o", "--out"));
	ВерсияПлатформы = ПараметрыКоманды["--v8version"];
	СтрокаПодключения = ДанныеПодключения.СтрокаПодключения;

	НомерСборки = ПараметрыКоманды["--build-number"];
	Если ЗначениеЗаполнено(НомерСборки) Тогда

		ИзменитьНомерСборкиВИсходникахКонфигурации(ПутьВходящий, НомерСборки);

	КонецЕсли;

	МенеджерКонфигуратора = Новый МенеджерКонфигуратора;

	ИмяРасширения = СтрЗаменить(Строка(Новый УникальныйИдентификатор), "-", "");
	Попытка
	 	ВТекущуюКонфигурацию = ОбщиеМетоды.ПолучитьПараметры(ПараметрыКоманды, "-c", "--current");
	 	Если ТипЗнч(ВТекущуюКонфигурацию) = Тип("Булево") И ВТекущуюКонфигурацию Тогда
			МенеджерКонфигуратора.Конструктор(ДанныеПодключения, ПараметрыКоманды);
		Иначе
			КаталогВременнойБазы = ВременныеФайлы.СоздатьКаталог();
			СтрокаПодключения = "/F""" + КаталогВременнойБазы + """";
			МенеджерКонфигуратора.Инициализация(ПараметрыКоманды, СтрокаПодключения, "", "", ВерсияПлатформы, ,
				ДанныеПодключения.КодЯзыка, ДанныеПодключения.КодЯзыкаСеанса);
			Конфигуратор = МенеджерКонфигуратора.УправлениеКонфигуратором();

			Конфигуратор.СоздатьФайловуюБазу(КаталогВременнойБазы);
		КонецЕсли;

	 	МенеджерКонфигуратора.СобратьИзИсходниковРасширение(
				 ПутьВходящий,
				 ИмяРасширения,
				Ложь);
		МенеджерКонфигуратора.ВыгрузитьРасширениеВФайл(ПутьИсходящий, ИмяРасширения);
	Исключение
		МенеджерКонфигуратора.Деструктор();
		ВызватьИсключение ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
	КонецПопытки;

	МенеджерКонфигуратора.Деструктор();

	Возврат МенеджерКомандПриложения.РезультатыКоманд().Успех;
КонецФункции

Процедура ИзменитьНомерСборкиВИсходникахКонфигурации(Знач ПутьИсходников, Знач НомерСборки)

	Лог.Информация("Изменяю номер сборки в исходниках конфигурации 1С на %1", НомерСборки);

	МенеджерВерсийФайлов1С = Новый МенеджерВерсийФайлов1С;
	СтарыеВерсии = МенеджерВерсийФайлов1С.УстановитьНомерСборкиДляКонфигурации(ПутьИсходников, НомерСборки);

	Для каждого КлючЗначение Из СтарыеВерсии Цикл
		Лог.Информация("    Старая версия %1, файл - %2", КлючЗначение.Значение, КлючЗначение.Ключ);
	КонецЦикла;

КонецПроцедуры
