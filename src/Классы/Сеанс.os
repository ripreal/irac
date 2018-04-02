Перем Сеанс_Ид;			// session
Перем Сеанс_Параметры;
Перем Сеанс_Лицензии;

Перем Кластер_Агент;
Перем Кластер_Владелец;
Перем ИБ_Владелец;

Перем ПараметрыОбъекта;

Перем ПериодОбновления;
Перем МоментАктуальности;

Перем Лог;

// Конструктор
//   
// Параметры:
//   АгентКластера		- АгентКластера			- ссылка на родительский объект агента кластера
//   Кластер			- Кластера				- ссылка на родительский объект кластера
//   ИБ					- ИнформационнаяБаза	- ссылка на родительский объект информационной базы
//   Ид					- Строка				- идентификатор сеанса
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер, ИБ, Ид)

	Если НЕ ЗначениеЗаполнено(Ид) Тогда
		Возврат;
	КонецЕсли;

	Кластер_Агент = АгентКластера;
	Кластер_Владелец = Кластер;
	ИБ_Владелец = ИБ;
	
	Сеанс_Ид = Ид;

	ПараметрыОбъекта = Новый ПараметрыОбъекта("session");

	ПериодОбновления = 60000;
	МоментАктуальности = 0;
	
	Сеанс_Лицензии		= Новый ОбъектыКластера(ЭтотОбъект);

КонецПроцедуры // ПриСозданииОбъекта()

// Процедура получает данные от сервиса администрирования кластера 1С
// и сохраняет в локальных переменных
//   
// Параметры:
//   ОбновитьПринудительно 		- Булево	- Истина - принудительно обновить данные (вызов RAC)
//											- Ложь - данные будут получены если истекло время актуальности
//													или данные не были получены ранее
//   
Процедура ОбновитьДанные(ОбновитьПринудительно = Ложь) Экспорт

	Если НЕ Служебный.ТребуетсяОбновление(Сеанс_Параметры,
			МоментАктуальности, ПериодОбновления, ОбновитьПринудительно) Тогда
		ОбновитьДанныеСеанса();
	КонецЕсли;

	Если НЕ Служебный.ТребуетсяОбновление(Сеанс_Лицензии,
			МоментАктуальности, ПериодОбновления, ОбновитьПринудительно) Тогда
		ОбновитьДанныеЛицензий();
	КонецЕсли;

	МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();

КонецПроцедуры // ОбновитьДанные()

// Процедура получает данные сеанса от сервиса администрирования кластера 1С
// и сохраняет в локальных переменных
//   
Процедура ОбновитьДанныеСеанса() Экспорт

	ПараметрыЗапуска = Новый Массив();
	ПараметрыЗапуска.Добавить(Кластер_Агент.СтрокаПодключения());

	ПараметрыЗапуска.Добавить("session");
	ПараметрыЗапуска.Добавить("info");

	ПараметрыЗапуска.Добавить(СтрШаблон("--session=%1", Сеанс_Ид));

	ПараметрыЗапуска.Добавить(СтрШаблон("--cluster=%1", Кластер_Владелец.Ид()));
	ПараметрыЗапуска.Добавить(Кластер_Владелец.СтрокаАвторизации());

	Служебный.ВыполнитьКоманду(ПараметрыЗапуска);
	
	МассивРезультатов = Служебный.РазобратьВыводКоманды(Служебный.ВыводКоманды());

	ТекОписание = МассивРезультатов[0];

	СтруктураПараметров = ПараметрыОбъекта();

	Процесс_Параметры = Новый Соответствие();

	Для Каждого ТекЭлемент Из СтруктураПараметров Цикл
		ЗначениеПараметра = Служебный.ПолучитьЗначениеИзСтруктуры(ТекОписание,
																  ТекЭлемент.Значение.ИмяПоляРАК,
																  ТекЭлемент.Значение.ЗначениеПоУмолчанию); 
		Процесс_Параметры.Вставить(ТекЭлемент.Ключ, ЗначениеПараметра);
	КонецЦикла;

КонецПроцедуры // ОбновитьДанныеСеанса()

// Процедура получает данные лицензии, выданной сеансу
// и сохраняет в локальных переменных
//   
Процедура ОбновитьДанныеЛицензий() Экспорт

	ПараметрыЗапуска = Новый Массив();
	ПараметрыЗапуска.Добавить(Кластер_Агент.СтрокаПодключения());

	ПараметрыЗапуска.Добавить("session");
	ПараметрыЗапуска.Добавить("info");

	ПараметрыЗапуска.Добавить("--licenses");

	ПараметрыЗапуска.Добавить(СтрШаблон("--session=%1", Сеанс_Ид));

	ПараметрыЗапуска.Добавить(СтрШаблон("--cluster=%1", Кластер_Владелец.Ид()));
	ПараметрыЗапуска.Добавить(Кластер_Владелец.СтрокаАвторизации());

	Служебный.ВыполнитьКоманду(ПараметрыЗапуска);
	
	Сеанс_Лицензии.Заполнить(Служебный.РазобратьВыводКоманды(Служебный.ВыводКоманды()));

КонецПроцедуры // ОбновитьДанныеЛицензий()

// Функция возвращает коллекцию параметров объекта
//   
// Параметры:
//   ИмяПоляКлюча 		- Строка	- имя поля, значение которого будет использовано
//									  в качестве ключа возвращаемого соответствия
//   
// Возвращаемое значение:
//	Соответствие - коллекция параметров объекта, для получения/изменения значений
//
Функция ПараметрыОбъекта(ИмяПоляКлюча = "ИмяПараметра") Экспорт

	Возврат ПараметрыОбъекта.Получить(ИмяПоляКлюча);

КонецФункции // ПараметрыОбъекта()

// Функция возвращает идентификатор сеанса 1С
//   
// Возвращаемое значение:
//	Строка - идентификатор сеанса 1С
//
Функция Ид() Экспорт

	Возврат Сеанс_Ид;

КонецФункции // Ид()

// Функция возвращает значение параметра сеанса 1С
//   
// Параметры:
//   ИмяПоля			 	- Строка		- Имя параметра сеанса
//   ОбновитьПринудительно 	- Булево		- Истина - обновить список (вызов RAC)
//
// Возвращаемое значение:
//	Произвольный - значение параметра сеанса 1С
//
Функция Получить(ИмяПоля, ОбновитьПринудительно = Ложь) Экспорт
	
	ОбновитьДанные(ОбновитьПринудительно);

	Если НЕ Найти(ВРег("Ид, process"), ВРег(ИмяПоля)) = 0 Тогда
		Возврат Сеанс_Ид;
	КонецЕсли;
	
	ЗначениеПоля = Сеанс_Параметры.Получить(ИмяПоля);

	Если ЗначениеПоля = Неопределено Тогда
		
		ОписаниеПараметра = ПараметрыОбъекта("ИмяПоляРАК").Получить(ИмяПоля);

		Если НЕ ОписаниеПараметра = Неопределено Тогда
			ЗначениеПоля = Сеанс_Параметры.Получить(ОписаниеПараметра["ИмяПараметра"]);
		КонецЕсли;
	КонецЕсли;

	Возврат ЗначениеПоля;
		
КонецФункции // Получить()
	
// Функция возвращает список лицензий, выданных сеансу 1С
//   
// Возвращаемое значение:
//	ОбъектыКластера - список лицензий, выданных сеансу 1С
//
Функция Лицензии() Экспорт
	
	Если Служебный.ТребуетсяОбновление(Сеанс_Лицензии, МоментАктуальности, ПериодОбновления) Тогда
		ОбновитьДанные(Истина);
	КонецЕсли;

	Возврат Сеанс_Лицензии;
	
КонецФункции // Лицензии()
	
Лог = Логирование.ПолучитьЛог("ktb.lib.irac");
