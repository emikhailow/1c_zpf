#Область БСП
Функция СведенияОВнешнейОбработке() Экспорт
	
	ПараметрыРегистрации = Новый Структура;
	ПараметрыРегистрации.Вставить("Вид", 				"ДополнительнаяОбработка");
	ПараметрыРегистрации.Вставить("Наименование", 		Метаданные().Представление()); //Наименование обработки, которым будет заполнено наименование элемента справочника
	ПараметрыРегистрации.Вставить("Версия", 			"1.0");
	ПараметрыРегистрации.Вставить("БезопасныйРежим", 	Ложь);
	ПараметрыРегистрации.Вставить("Информация", 		Метаданные().Представление()); //Краткая информация по обработке, описание обработки
	ПараметрыРегистрации.Вставить("ВерсияБСП", 			"1.2.1.4");
	ТаблицаКоманд = ПолучитьТаблицуКоманд();
	ДобавитьКоманду(ТаблицаКоманд,
	Метаданные().Представление(),
	"1",
	"ОткрытиеФормы",
	Истина);
	ПараметрыРегистрации.Вставить("Команды", ТаблицаКоманд);
	
	НоваяКоманда 				= ПараметрыРегистрации.Команды.Добавить();
	НоваяКоманда.Представление 	= "(БИТ) Выгрузить данные по сотрудникам во Фронтол";
	НоваяКоманда.Идентификатор 	= "ВыгрузитьДанныеПоСотрудникамНаКассы";
	НоваяКоманда.Использование 	= ДополнительныеОтчетыИОбработкиКлиентСервер.ТипКомандыВызовСерверногоМетода();
	
	Возврат ПараметрыРегистрации;
	
КонецФункции

Функция ПолучитьТаблицуКоманд()
	
	Команды = Новый ТаблицаЗначений;
	Команды.Колонки.Добавить("Представление", Новый ОписаниеТипов("Строка"));
	Команды.Колонки.Добавить("Идентификатор", Новый ОписаниеТипов("Строка"));
	Команды.Колонки.Добавить("Использование", Новый ОписаниеТипов("Строка"));
	Команды.Колонки.Добавить("ПоказыватьОповещение", Новый ОписаниеТипов("Булево"));
	Команды.Колонки.Добавить("Модификатор", Новый ОписаниеТипов("Строка"));
	Возврат Команды;
	
КонецФункции  

Процедура ДобавитьКоманду(ТаблицаКоманд, Представление, Идентификатор, Использование, ПоказыватьОповещение = Ложь, Модификатор = "")
	
	НоваяКоманда = ТаблицаКоманд.Добавить();
	НоваяКоманда.Представление = Представление;
	НоваяКоманда.Идентификатор = Идентификатор;
	НоваяКоманда.Использование = Использование;
	НоваяКоманда.ПоказыватьОповещение = ПоказыватьОповещение;
	НоваяКоманда.Модификатор = Модификатор;
	
КонецПроцедуры

Функция ВыполнитьКоманду(ИдентификаторКоманды, ПараметрыКоманды) Экспорт
	
	Если ИдентификаторКоманды = "ВыгрузитьДанныеПоСотрудникамНаКассы" Тогда
		
		ЗаполнитьТЧКассы();
		ВыгрузитьДанныеПоСотрудникамНаКассы();
		
	КонецЕсли;
	
КонецФункции
#КонецОбласти

Процедура ВыгрузитьДанныеПоСотрудникамНаКассы() Экспорт
	
	НайденныеСтроки = Кассы.НайтиСтроки(Новый Структура("Пометка", Истина));
		
	Если Не НайденныеСтроки.Количество() Тогда
		Возврат;
	КонецЕсли;
	
	Файл = СформироватьФайлЗагрузки();
	
	Для Каждого Строка Из НайденныеСтроки Цикл
		
		Параметры = Справочники.ПодключаемоеОборудование.ПолучитьДанныеУстройства(Строка.ПодключаемоеОборудование).Параметры;
		
		Если ЗначениеЗаполнено(Параметры.БазаТоваров)Тогда
			
			ФайлФлаг = Новый Файл(Параметры.ФлагВыгрузки);
			Если НЕ ФайлФлаг.Существует() Тогда
				Попытка
					Файл.Записать(Параметры.БазаТоваров, КодировкаТекста.ANSI);
				Исключение
				КонецПопытки;
				
				ОжиданиеДо = ТекущаяДата() + 10;
				Пока ТекущаяДата() < ОжиданиеДо Цикл
				КонецЦикла;
				
				Попытка
					
					ТекстФлаг = Новый ТекстовыйДокумент;
					ТекстФлаг.Записать(Параметры.ФлагВыгрузки, КодировкаТекста.ANSI);
					
				Исключение
				КонецПопытки;
				
				Сообщить(СтрШаблон("Файл %1 выгружен", Параметры.БазаТоваров));
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ЗаполнитьТЧКассы() Экспорт
	
	Запрос = Новый Запрос(
	"ВЫБРАТЬ
	|	ПодключаемоеОборудование.Ссылка КАК ПодключаемоеОборудование,
	|	ПодключаемоеОборудование.РабочееМесто КАК РабочееМесто
	|ПОМЕСТИТЬ ВТ_ПодключаемоеОборудование
	|ИЗ
	|	Справочник.ПодключаемоеОборудование КАК ПодключаемоеОборудование
	|ГДЕ
	|	ПодключаемоеОборудование.ТипОборудования = ЗНАЧЕНИЕ(Перечисление.ТипыПодключаемогоОборудования.ККМОфлайн)
	|	И ПодключаемоеОборудование.ПометкаУдаления = ЛОЖЬ
	|	И ПодключаемоеОборудование.УстройствоИспользуется = ИСТИНА
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	ПодключаемоеОборудование
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	НастройкиРМККассы.ПодключаемоеОборудование КАК ПодключаемоеОборудование,
	|	НастройкиРМККассы.Касса КАК Касса
	|ПОМЕСТИТЬ ВТ_Кассы
	|ИЗ
	|	Справочник.НастройкиРМК.Кассы КАК НастройкиРМККассы
	|ГДЕ
	|	(НастройкиРМККассы.ПодключаемоеОборудование, НастройкиРМККассы.Ссылка.РабочееМесто) В
	|			(ВЫБРАТЬ
	|				ВТ_ПодключаемоеОборудование.ПодключаемоеОборудование КАК ПодключаемоеОборудование,
	|				ВТ_ПодключаемоеОборудование.РабочееМесто КАК РабочееМесто
	|			ИЗ
	|				ВТ_ПодключаемоеОборудование КАК ВТ_ПодключаемоеОборудование)
	|
	|СГРУППИРОВАТЬ ПО
	|	НастройкиРМККассы.ПодключаемоеОборудование,
	|	НастройкиРМККассы.Касса
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	ПодключаемоеОборудование
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	НастройкиРМККассыККМ.ПодключаемоеОборудование КАК ПодключаемоеОборудование,
	|	МАКСИМУМ(НастройкиРМККассыККМ.КассаККМ) КАК КассаККМ
	|ПОМЕСТИТЬ ВТ_КассыККМ
	|ИЗ
	|	Справочник.НастройкиРМК.КассыККМ КАК НастройкиРМККассыККМ
	|ГДЕ
	|	(НастройкиРМККассыККМ.ПодключаемоеОборудование, НастройкиРМККассыККМ.Ссылка.РабочееМесто) В
	|			(ВЫБРАТЬ
	|				ВТ_ПодключаемоеОборудование.ПодключаемоеОборудование КАК ПодключаемоеОборудование,
	|				ВТ_ПодключаемоеОборудование.РабочееМесто КАК РабочееМесто
	|			ИЗ
	|				ВТ_ПодключаемоеОборудование КАК ВТ_ПодключаемоеОборудование)
	|
	|СГРУППИРОВАТЬ ПО
	|	НастройкиРМККассыККМ.ПодключаемоеОборудование
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	ПодключаемоеОборудование
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ИСТИНА КАК Пометка,
	|	ВТ_ПодключаемоеОборудование.ПодключаемоеОборудование КАК ПодключаемоеОборудование,
	|	ЕСТЬNULL(ВТ_Кассы.Касса, ЗНАЧЕНИЕ(Справочник.Кассы.ПустаяСсылка)) КАК Касса,
	|	ЕСТЬNULL(ВТ_КассыККМ.КассаККМ, ЗНАЧЕНИЕ(Справочник.КассыККМ.ПустаяСсылка)) КАК КассаККМ,
	|	ВТ_ПодключаемоеОборудование.ПодключаемоеОборудование.ПравилоОбмена.Склад КАК Склад
	|ИЗ
	|	ВТ_ПодключаемоеОборудование КАК ВТ_ПодключаемоеОборудование
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_Кассы КАК ВТ_Кассы
	|		ПО ВТ_ПодключаемоеОборудование.ПодключаемоеОборудование = ВТ_Кассы.ПодключаемоеОборудование
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_КассыККМ КАК ВТ_КассыККМ
	|		ПО ВТ_ПодключаемоеОборудование.ПодключаемоеОборудование = ВТ_КассыККМ.ПодключаемоеОборудование
	|
	|УПОРЯДОЧИТЬ ПО
	|	ПодключаемоеОборудование
	|АВТОУПОРЯДОЧИВАНИЕ");
	Кассы.Загрузить(Запрос.Выполнить().Выгрузить());	
	
КонецПроцедуры

Функция СформироватьФайлЗагрузки()

	Текст = Новый ТекстовыйДокумент();
	Текст.ДобавитьСтроку("##@@&&");
	Текст.ДобавитьСтроку("#");
	Текст.ДобавитьСтроку("$$$DELETEALLCCARDDISCS");
	Текст.ДобавитьСтроку("$$$DELETEALLCLIENTCCARDS");
	
	ТекстСвязьСКлассификаторами = Новый ТекстовыйДокумент();
	ТекстСвязьСКлассификаторами.ДобавитьСтроку("$$$ADDCLASSIFIERLINKS");		// Добавить связи с классификаторами
	
	ТекстКарты = Новый ТекстовыйДокумент();
	ТекстКарты.ДобавитьСтроку("$$$ADDCCARDDISCS");								// Добавить карты
	
	ТекстКлиенты= Новый ТекстовыйДокумент();
	ТекстКлиенты.ДобавитьСтроку("$$$ADDCLIENTDISCS");							// Добавить клиентов
	
	ТекстСвязьКартыСКлиентом= Новый ТекстовыйДокумент();
	ТекстСвязьКартыСКлиентом.ДобавитьСтроку("$$$ADDCLIENTCCARDS");				// Добавить связь карты с клиентом
		
	ТЗ = ПолучитьТЗКартыСотрудниковИзЗУП();
	Для Каждого Строка Из ТЗ Цикл
		
		КодКарты 	= Формат(1073741824 + ПолучитьHash(Строка.Карта), "ЧГ=");
		КодКлиента 	= Формат(1073741824 + ПолучитьHash(Строка.ТабельныйНомер), "ЧГ=");
		
		ТекстКарты.ДобавитьСтроку(Строка(КодКарты) + ";1;" + Строка.Карта + ";;;1");
		ТекстКлиенты.ДобавитьСтроку(Строка(КодКлиента) + ";0;" + Строка.ФИО + ";" + Строка.ФИО + ";;;;;;;;;;;;;;" + Строка.ТабельныйНомер);
		ТекстСвязьКартыСКлиентом.ДобавитьСтроку(Строка(КодКлиента) + ";1;" + Строка(КодКарты));
		Если Строка.ЭтоСтудент Тогда
			ТекстСвязьСКлассификаторами.ДобавитьСтроку("999;2;" + Строка(КодКлиента));
		КонецЕсли;
		
	КонецЦикла;
	
	Текст.ДобавитьСтроку(ТекстКарты.ПолучитьТекст());
	Текст.ДобавитьСтроку(ТекстКлиенты.ПолучитьТекст());
	Текст.ДобавитьСтроку(ТекстСвязьКартыСКлиентом.ПолучитьТекст());
	Текст.ДобавитьСтроку(ТекстСвязьСКлассификаторами.ПолучитьТекст());
	
	Возврат Текст;
	
КонецФункции

Функция ПолучитьТЗКартыСотрудниковИзЗУП() Экспорт
	
	ТЗ = Новый ТаблицаЗначений;
	ТЗ.Колонки.Добавить("ФИО");
	ТЗ.Колонки.Добавить("ТабельныйНомер");
	ТЗ.Колонки.Добавить("Карта");
	ТЗ.Колонки.Добавить("ЭтоСтудент");
	
	ИнформационнаяБазаCOM = ПолучитьПодключениеПоCOM(Истина);
	Если ИнформационнаяБазаCOM <> Неопределено Тогда
		
		ЗапросCOM = ИнформационнаяБазаCOM.NewObject("Запрос");
		ЗапросCOM.Текст = "ВЫБРАТЬ
		|	бит_КартыСотрудниковСрезПоследних.Сотрудник КАК Сотрудник,
		|	бит_КартыСотрудниковСрезПоследних.Карта КАК Карта
		|ПОМЕСТИТЬ ВТСотрудники
		|ИЗ
		|	РегистрСведений.бит_КартыСотрудников.СрезПоследних КАК бит_КартыСотрудниковСрезПоследних
		
		|ИНДЕКСИРОВАТЬ ПО
		|	Сотрудник
		|;
		
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ДолжностиДополнительныеРеквизиты.Ссылка КАК Должность
		|ПОМЕСТИТЬ ВТДолжностьЭтоСтудент
		|ИЗ
		|	Справочник.Должности.ДополнительныеРеквизиты КАК ДолжностиДополнительныеРеквизиты
		|ГДЕ
		|	ДолжностиДополнительныеРеквизиты.Свойство.Имя = ""Должность_ЭтоСтудент""
		|	И (ВЫРАЗИТЬ(ДолжностиДополнительныеРеквизиты.Значение КАК БУЛЕВО)) = ИСТИНА
		|;
		
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	КадроваяИсторияСотрудниковИнтервальный.Сотрудник КАК Сотрудник
		|ПОМЕСТИТЬ ВТСтуденты
		|ИЗ
		|	РегистрСведений.КадроваяИсторияСотрудниковИнтервальный КАК КадроваяИсторияСотрудниковИнтервальный
		|ГДЕ
		|	&ТекущаяДата МЕЖДУ КадроваяИсторияСотрудниковИнтервальный.ДатаНачала И КадроваяИсторияСотрудниковИнтервальный.ДатаОкончания
		|	И КадроваяИсторияСотрудниковИнтервальный.Сотрудник В
		|			(ВЫБРАТЬ
		|				ВТСотрудники.Сотрудник КАК Сотрудник
		|			ИЗ
		|				ВТСотрудники КАК ВТСотрудники)
		|	И КадроваяИсторияСотрудниковИнтервальный.Должность В
		|			(ВЫБРАТЬ
		|				ВТДолжностьЭтоСтудент.Должность КАК Должность
		|			ИЗ
		|				ВТДолжностьЭтоСтудент КАК ВТДолжностьЭтоСтудент)
		|;
		
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТСотрудники.Сотрудник.Наименование КАК ФИО,
		|	ВТСотрудники.Сотрудник.Код КАК ТабельныйНомер,
		|	ВТСотрудники.Карта КАК Карта,
		|	ВЫБОР
		|		КОГДА ЕСТЬNULL(ВТСтуденты.Сотрудник, НЕОПРЕДЕЛЕНО) = НЕОПРЕДЕЛЕНО
		|			ТОГДА ЛОЖЬ
		|		ИНАЧЕ ИСТИНА
		|	КОНЕЦ КАК ЭтоСтудент
		|ИЗ
		|	ВТСотрудники КАК ВТСотрудники
		|		ЛЕВОЕ СОЕДИНЕНИЕ ВТСтуденты КАК ВТСтуденты
		|		ПО ВТСотрудники.Сотрудник = ВТСтуденты.Сотрудник";
		ЗапросCOM.УстановитьПараметр("ТекущаяДата", ТекущаяДата());
		Выборка = ЗапросCOM.Выполнить().Выбрать();
		Пока Выборка.Следующий() Цикл
			ЗаполнитьЗначенияСвойств(ТЗ.Добавить(), Выборка);	
		КонецЦикла;
		
	КонецЕсли;
	
	Возврат ТЗ;
	
КонецФункции

Функция ПолучитьHash(СтрHash, Hash = 0, M = 31, РазмерТаблицы = 536870912) Экспорт
	
	ДлинаСтроки = СтрДлина(СтрHash);
	Для нПоз = 1 По ДлинаСтроки Цикл
		Hash = M * Hash + КодСимвола(Сред(СтрHash, нПоз, 1));
	КонецЦикла;
	Возврат Hash % РазмерТаблицы;
	
КонецФункции

Функция ПолучитьПодключениеПоCOM(ПараметрыПодключенияПоУмолчанию = Ложь);
	
	Если ПараметрыПодключенияПоУмолчанию = Истина Тогда
		ЗаполнитьПараметрыПодключенияCOMПоУмолчанию();	
	КонецЕсли;
	
	Если ЗначениеЗаполнено(АдресПодключениеПоCOM) Тогда
		
		СтруктураПодключениеПоCOM = ПолучитьИзВременногоХранилища(АдресПодключениеПоCOM);	
		Если СтруктураПодключениеПоCOM = Неопределено Тогда
			
			ПодключениеПоCOM = СоздатьНовоеПодключениеПоCOM();
			Если ПодключениеПоCOM <> Неопределено Тогда
				
				СтруктураПодключениеПоCOM = Новый Структура("COMОбъект", ПодключениеПоCOM);
				АдресПодключениеПоCOM = ПоместитьВоВременноеХранилище(СтруктураПодключениеПоCOM, Новый УникальныйИдентификатор);	
				
			КонецЕсли;			
			
		Иначе
			Возврат СтруктураПодключениеПоCOM.COMОбъект; 		
		КонецЕсли;
		
	Иначе 
		
		ПодключениеПоCOM = СоздатьНовоеПодключениеПоCOM();
		Если ПодключениеПоCOM <> Неопределено Тогда
			
			СтруктураПодключениеПоCOM = Новый Структура("COMОбъект", ПодключениеПоCOM);
			АдресПодключениеПоCOM = ПоместитьВоВременноеХранилище(СтруктураПодключениеПоCOM, Новый УникальныйИдентификатор);	
			
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат ПодключениеПоCOM;
	
КонецФункции

Функция СоздатьНовоеПодключениеПоCOM() Экспорт
	
	СтрокаПодключенияКБазеCOM = СтрШаблон("Srvr=""%1""; Ref=""%2""; Usr=""%3""; Pwd=""%4""", 
	Srvr, Ref, Usr, Pwd);
	V83COMConnector = Новый COMОбъект("V83.COMConnector");
	Попытка
		ПодключениеПоCOM =  V83COMConnector.Connect(СтрокаПодключенияКБазеCOM);
	Исключение
		
		Сообщить(ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		Возврат Неопределено;
		
	КонецПопытки;
	
	Возврат ПодключениеПоCOM;	
	
КонецФункции

Процедура ЗаполнитьПараметрыПодключенияCOMПоУмолчанию()

	Srvr 	= "zel-1c1";
	Ref 	= "ZUP";
	Usr 	= "Администратор";
	Pwd 	= "111";

КонецПроцедуры

