Перем Кластер_Агент;
Перем Кластер_Владелец;
Перем ПараметрыОбъекта;
Перем Элементы;

Перем Лог;

// Конструктор
//   
// Параметры:
//   АгентКластера		- АгентКластера	- ссылка на родительский объект агента кластера
//   Кластер			- Кластер		- ссылка на родительский объект кластера
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер)

	Кластер_Агент = АгентКластера;
	Кластер_Владелец = Кластер;

	ПараметрыОбъекта = Новый КомандыОбъекта("manager");

	Элементы = Новый ОбъектыКластера(ЭтотОбъект);

КонецПроцедуры

// Процедура получает данные от сервиса администрирования кластера 1С
// и сохраняет в локальных переменных
//   
// Параметры:
//   ОбновитьПринудительно 		- Булево	- Истина - принудительно обновить данные (вызов RAC)
//											- Ложь - данные будут получены если истекло время актуальности
//													или данные не были получены ранее
//   
Процедура ОбновитьДанные(ОбновитьПринудительно = Ложь) Экспорт
	
	Если НЕ Элементы.ТребуетсяОбновление(ОбновитьПринудительно) Тогда
		Возврат;
	КонецЕсли;
	
	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"  , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("СтрокаАвторизацииКластера", Кластер_Владелец.СтрокаАвторизации());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"    , Кластер_Владелец.Ид());
	
	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = Кластер_Агент.ВыполнитьКоманду(ПараметрыОбъекта.ПараметрыКоманды("Список"));

	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка получения списка менеджеров кластера, КодВозврата = %1: %2",
									КодВозврата,
									Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;

	Элементы.Заполнить(Кластер_Агент.ВыводКоманды());

	Элементы.УстановитьАктуальность();

КонецПроцедуры // ОбновитьДанные()

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

	Возврат ПараметрыОбъекта.ОписаниеСвойств(ИмяПоляКлюча);

КонецФункции // ПараметрыОбъекта()

// Функция возвращает список менеджеров кластера
//   
// Параметры:
//   Отбор					 	- Структура	- Структура отбора менеджеров (<поле>:<значение>)
//   ОбновитьПринудительно 		- Булево	- Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//	Массив - список менеджеров кластера 1С
//
Функция Список(Отбор = Неопределено, ОбновитьПринудительно = Ложь) Экспорт

	МенеджерыКластера = Элементы.Список(Отбор, ОбновитьПринудительно);
	
	Возврат МенеджерыКластера;

КонецФункции // Список()

// Функция возвращает список менеджеров кластера 1С
//   
// Параметры:
//   ПоляИерархии 			- Строка		- Поля для построения иерархии списка менеджеров, разделенные ","
//   ОбновитьПринудительно 	- Булево		- Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//	Соответствие - список менеджеров кластера 1С
//		<имя поля объекта>	- Массив(Соответствие), Соответствие	- список менеджеров или следующий уровень
//
Функция ИерархическийСписок(Знач ПоляИерархии, ОбновитьПринудительно = Ложь) Экспорт

	МенеджерыКластера = Элементы.ИерархическийСписок(ПоляИерархии, ОбновитьПринудительно);

	Возврат МенеджерыКластера;

КонецФункции // ИерархическийСписок()

// Функция возвращает количество менеджеров кластера в списке
//   
// Возвращаемое значение:
//	Число - количество менеджеров кластера
//
Функция Количество() Экспорт

	Если Элементы = Неопределено Тогда
		Возврат 0;
	КонецЕсли;
	
	Возврат Элементы.Количество();

КонецФункции // Количество()

// Функция возвращает описание менеджера кластера 1С
//   
// Параметры:
//   Менеджер			 	- Строка	- Номер менеджер в виде <адрес сервера>:<номер процесса ОС (pid))>
//   ОбновитьПринудительно 	- Булево	- Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//	Соответствие - описание менеджера кластера 1С
//
Функция Получить(Знач Менеджер, Знач ОбновитьПринудительно = Ложь) Экспорт

	Менеджер = СтрРазделить(Менеджер, ":");

	Если Менеджер.Количество() = 1 Тогда
		Менеджер.Вставить(0, Кластер_Владелец.Получить("host"));
	КонецЕсли;

	Отбор = Новый Соответствие();
	Отбор.Вставить("host", Менеджер[0]);
	Отбор.Вставить("pid", Менеджер[1]);

	МенеджерыКластера = Элементы.Список(Отбор, ОбновитьПринудительно);

	Если МенеджерыКластера.Количество() = 0 Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат МенеджерыКластера[0];

КонецФункции // Получить()

Лог = Логирование.ПолучитьЛог("ktb.lib.irac");
