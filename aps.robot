*** Settings ***
Library           op_robot_tests.tests_files.service_keywords
Library           String
Library           Collections
Library           Selenium2Library
Library           DebugLibrary
Resource          ../../op_robot_tests/tests_files/keywords.robot
Resource          ../../op_robot_tests/tests_files/resource.robot
Resource          Locators.robot
Library           DateTime
Library           conv_timeDate.py

*** Variables ***
${id}             UA-2017-03-14-000099
${js}             ${EMPTY}

*** Keywords ***
Підготувати клієнт для користувача
    [Arguments]    ${username}
    [Documentation]    Відкриває переглядач на потрібній сторінці, готує api wrapper тощо
    ${user}=    Get From Dictionary    ${USERS.users}    ${username}
    Open Browser    ${user.homepage}    ${user.browser}
    Set Window Position    @{user.position}
    Comment    Log To Console
    Set Window Size    @{user.size}
    Run Keyword If    '${role}'!='aps_Viewer'    Login    ${user}
    Comment    Run Keyword If    '${role}'='aps_Viewer'    ${user}

aps.Адаптувати дані для оголошення тендера
    [Arguments]    ${username}    ${tender_data}
    [Documentation]    Змінює деякі поля в tender_data (автоматично згенерованих даних для оголошення тендера) згідно з особливостями майданчика
    [Return]    ${y}

aps.Створити тендер
    [Arguments]    ${g}    ${tender_data}
    [Documentation]    Створює однопредметний тендер
    Log To Console    ${SUITE_NAME}
    Comment    Wait Until Element Is Visible    ${locator_button_create}    5
    Comment    Click Element    ${locator_button_create}
    Run Keyword If    '${SUITE_NAME}'=='Tests Files.singleItemTender'    Допороговый однопредметный тендер    ${tender_data}
    Run Keyword If    ${SUITE_NAME}'=='Tests Files.openEU.robot    Открытые торги с публикацией на англ    ${tender_data}
    Run Keyword If    ${SUITE_NAME}'=='Tests Files.openUA.robot    Открытые торги с публикацией на укр    ${tender_data}
    Run Keyword If    ${SUITE_NAME}'=='Tests Files.negotiation.robot    Переговорная мультилотовая процедура    ${tender_data}
    Run Keyword If    ${SUITE_NAME}'=='Tests Files.singleItemTenderComplaints.robot    Работа с жалобами    ${tender_data}
    [Return]    ${UAID}

aps.Внести зміни в тендер
    [Arguments]    ${username}    ${tender_uaid}    ${field_name}    ${field_value}
    [Documentation]    Змінює значення поля field_name на field_value в тендері tender_uaid
    aps.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
    Wait Until Element Is Enabled    ${loc_TenderPublishTop}
    Click Element    ${loc_TenderPublishTop}

Завантажити документ
    [Arguments]    ${username}    ${filepath}    ${tender_uaid}
    [Documentation]    Завантажує супроводжуючий тендерний документ в тендер tender_uaid. Тут аргумент filepath – це шлях до файлу на диску

aps.Пошук тендера по ідентифікатору
    [Arguments]    ${username}    ${tender_uaid}
    [Documentation]    Знаходить тендер по його UAID, відкриває його сторінку
    Поиск тендера по идентификатору

Оновити сторінку з тендером
    [Arguments]    ${username}    ${tender_uaid}
    [Documentation]    Оновлює інформацію на сторінці, якщо відкрита сторінка з тендером, інакше переходить на сторінку з тендером tender_uaid

Отримати інформацію із тендера
    [Arguments]    ${username}    ${field_name}
    [Documentation]    Return значення поля field_name, яке бачить користувач username
    [Return]    field_value

Задати питання
    [Arguments]    ${username}    ${tender_uaid}    ${question}
    [Documentation]    Задає питання question від імені користувача username в тендері tender_uaid

Відповісти на питання
    [Arguments]    ${username}    ${tender_uaid}    ${question}    ${answer_data}    ${question_id}
    [Documentation]    [Documentation] Відповідає на запитання question з ID question_id в тендері tender_uaid відповіддю answer_data

Подати цінову пропозицію
    [Arguments]    ${username}    ${tender_uaid}    ${bid}
    [Documentation]    Створює нову ставку в тендері tender_uaid
    [Return]    Дані про подану ставку для можливості її подальшої зміни або скасування

Змінити цінову пропозицію
    [Arguments]    ${username}    ${tender_uaid}    ${fieldname}    ${fieldvalue}
    [Documentation]    Змінює поле fieldname (сума, неціновий показник тощо) в раніше створеній ставці в тендері tender_uaid

Скасувати цінову пропозицію
    [Arguments]    ${username}    ${tender_uaid}    ${bid}
    [Documentation]    Скасовує ставку bid в тендері tender_uaid

Завантажити документ в ставку
    [Arguments]    ${username}    ${filepath}    ${tender_uaid}
    [Documentation]    Завантажує документ в ставку в тендері tender_uaid
    [Return]    Результат завантаження – ідентифікатор / назва / тип документа / інші дані, потрібні для подальшої зміни документа в ставці

Змінити документ в ставці
    [Arguments]    ${username}    ${filepath}    ${bidid}    ${docid}
    [Documentation]    Змінює документ з ідентифікатором docid в ставці bidid (у випадку однопредметного тендера bidid може бути порожім). Тут аргументfilepath – це шлях до файлу на диску
    [Return]    Результат завантаження

Отримати посилання на аукціон для глядача
    [Arguments]    ${username}    ${tender_uaid}
    [Documentation]    Отримує посилання на перегляд аукціону тендера tender_uaid в якості спостерігача
    [Return]    URL сторінки аукціону

Отримати посилання на аукціон для учасника
    [Arguments]    ${username}    ${tender_uaid}
    [Documentation]    Отримує посилання на участь в аукціоні тендера tender_uaid в якості учасника
    [Return]    URL сторінки аукціону

Login
    [Arguments]    ${user}
    Wait Until Element Is Visible    ${locator_cabinetEnter}    10
    Click Element    ${locator_cabinetEnter}
    Click Element    ${locator_enter}
    Wait Until Element Is Visible    ${locator_emailField}    10
    Input Text    ${locator_emailField}    ${user.login}
    Input Text    ${locator_passwordField}    ${user.password}
    Click Element    ${locator_loginButton}

Информация по закупке
    [Arguments]    ${enquiryPeriod}    ${tenderPeriod}    ${tender_data}
    #Ввод названия тендера
    Wait Until Element Is Visible    ${locator_tenderTitle}
    ${descr}=    Get From Dictionary    ${tender_data.data}    description
    Input Text    ${locator_tenderTitle}    ${descr}
    #Выбор НДС
    ${PDV}=    Get From Dictionary    ${tender_data.data.value}    valueAddedTaxIncluded
    Click Element    ${locator_pdv}
    Execute Javascript    window.scroll(1000, 1000)
    #Валюта
    Click Element    ${locator_currency}
    ${currency}=    Get From Dictionary    ${tender_data.data.value}    currency
    Select From List By Label    xpath=.//*[@ng-controller='currencySelectController']/select    ${currency}
    Comment    Input Text    ${locator_currency}    ${currency}
    #Ввод бюджета
    ${budget}=    Get From Dictionary    ${tender_data.data.value}    amount
    ${text}=    Convert To string    ${budget}
    Comment    Log To Console    ${text}
    ${text}=    String.Replace String    ${text}    .    ,
    Input Text    ${locator_budget}    ${text}
    #Ввод мин шага
    ${min_step}=    Get From Dictionary    ${tender_data.data.minimalStep}    amount
    ${text_ms}=    Convert To string    ${min_step}
    ${text_ms}=    String.Replace String    ${text_ms}    .    ,
    Input Text    ${locator_min_step}    ${text_ms}
    #Период уточнений нач дата
    ${enquiry start}=    Get From Dictionary    ${enquiryPeriod}    startDate
    ${date_time}=    dt    ${enquiry start}
    ${js}=    Set Variable    $('#period_enquiry_start').val('${date_time}');
    Log To Console    $('#period_enquiry_start').val('${date_time}');
    Execute Javascript    ${js}
    Comment    Input Text    ${locator_discussionDate_start}    ${date_time}
    #Период уточнений кон дата
    ${enquiry end}=    Get From Dictionary    ${enquiryPeriod}    endDate
    ${date_time}=    dt    ${enquiry end}
    Comment    Input Text    ${locator_discussionDate_end}    ${date_time}
    Execute Javascript    ${js}    $('#period_enquiry_end').val('${date_time}');
    #Период приема предложений (нач дата)
    ${tender_start}=    Get From Dictionary    ${tenderPeriod}    startDate
    ${date_time}=    dt    ${tender_start}
    Comment    Input Text    ${locator_bidDate_start}    ${date_time}
    Execute Javascript    ${js}    $('#period_tender_start').val('${date_time}');
    #Период приема предложений (кон дата)
    ${tender_end}=    Get From Dictionary    ${tenderPeriod}    endDate
    ${date_time}=    dt    ${tender_end}
    Comment    Input Text    ${locator_bidDate_end}    ${date_time}
    Execute Javascript    ${js}    $('#period_tender_end').val('${date_time}');
    sleep    15
    Click Button    ${locator_button_next_step}
    Log To Console    1111111
    sleep    15

Информация по позиции

Добавить позицию
    [Arguments]    ${item}
    #Клик доб позицию
    Comment    Wait Until Element Is Visible    ${locator_add_item_button}
    Comment    Click Button    ${locator_add_item_button}
    Wait Until Page Contains    ${locator_item_description}
    Wait Until Element Is Visible    ${locator_item_description}    10
    #Название предмета закупки
    ${add_classif}=    Get From Dictionary    ${item}    additionalClassifications
    ${itemDescript}=    Get From List    ${add_classif}    0
    ${itemDescript}=    Get From Dictionary    ${itemDescript}    description
    Input Text    ${locator_item_description}    ${itemDescript}
    #Количество товара
    ${editItemQuant}=    Get From Dictionary    ${item}    quantity
    Input Text    ${locator_Quantity}    ${editItemQuant}
    #Выбор ед измерения
    Wait Until Element Is Enabled    ${locator_code}
    ${code}=    Get From Dictionary    ${item.unit}    code
    Select From List By Value    ${locator_code}    ${code}
    #Выбор ДК
    Click Button    ${locator_button_add_cpv}
    Wait Until Element Is Visible    ${locator_cpv_search}
    ${cpv}=    Get From Dictionary    ${item.classification}    id
    Input Text    ${locator_cpv_search}    ${cpv}
    Click Button    ${locator_add_classifier}
    #Выбор др ДК
    Wait Until Element Is Visible    ${locator_button_add_dkpp}
    Click Button    ${locator_button_add_dkpp}
    Wait Until Element Is Visible    ${locator_dkpp_search}
    ${dkpp}=    Get From Dictionary    ${item.additionalClassifications}    id
    Input Text    ${locator_dkpp_search}    ${dkpp}
    Click Button    ${locator_add_classfier}
    #Срок поставки (конечная дата)
    ${delivery_Date}=    Get From Dictionary    ${item.deliveryDate}    endDate
    ${date_time}=    dt    ${delivery_Date}
    Input Text    ${locator_date_delivery_end}    ${date_time}
    #Клик Enter
    Press Key    ${locator_date_delivery_end}    \\\13
    Execute Javascript    window.scroll(-1000, -1000)
    Click Element    ${locator_check_location}
    ${country}=    Get From Dictionary    ${item.deliveryAddress}    countryName
    Input Text    ${locator_country_id}    ${country}
    ${region}=    Get From Dictionary    ${item.deliveryAddress}    region
    Input Text    ${locator_SelectRegion}    ${region}
    ${post_code}=    Get From Dictionary    ${item.deliveryAddress}    postalCode
    Input Text    ${locator_postal_code}    ${post_code}
    ${locality}=    Get From Dictionary    ${item.deliveryAddress}    locality
    Input Text    ${locator_locality}    ${locality}
    ${street}=    Get From Dictionary    ${item.deliveryAddress}    streetAddress
    Input Text    ${locator_street}    ${street}
    #Клик кнопку "Створити"
    Click Element    ${locator_button_create_item}

date_Time
    [Arguments]    ${date}
    ${DT}=    Convert Date    ${date}    date_format=
    Return From Keyword    '${DT.day}'+'.'+'${DT.month}'+'.'+'${DT.year}'+' '+'${DT.hour}'+':'+'${DT.minute}'
    [Return]    ${aps_date}

Опубликовать закупку
    Click Element    ${loc_TenderPublishTop}
    Wait Until Element Is Enabled    ${loc_PublishConfirm}
    Click Element    xpath=.//*[@id='optionsRadiosNotEcp']/..
    Click Button    xpath=.//*[@class='btn btn-success ecp_true hidden']

Допороговый однопредметный тендер
    [Arguments]    ${tender_data}
    Wait Until Element Is Visible    ${locator_button_create}    15
    Click Button    ${locator_button_create}
    Wait Until Element Is Visible    ${locator_create_dop_zak}    8
    Click Element    ${locator_create_dop_zak}
    Wait Until Element Is Visible    ${locator_tenderTitle}    15    #Wait Until Page Contains Element
    Информация по закупке    ${tender_data.data.enquiryPeriod}    ${tender_data.data.tenderPeriod}    ${tender_data}
    Comment    Click Button    ${locator_button_next_step}
    ${trtte}=    Get From Dictionary    ${tender_data}    data
    ${ttt}=    Get From Dictionary    ${trtte}    items
    ${item}=    Get From List    ${ttt}    0
    Comment    Execute Javascript    window.scroll(800, 800)
    Добавить позицию    ${item}
    Execute Javascript    window.scroll(1000, 1000)
    Click Element    ${loc.sumbit}
    Execute Javascript    window.scroll(-1000,-1000)
    ${UAID}=    Опубликовать закупку

Открытые торги с публикацией на англ

Открытые торги с публикацией на укр
    [Arguments]    ${arg1}

Переговорная мультилотовая процедура
    [Arguments]    ${arg1}

Работа с жалобами

Открыть форму создания тендера
    Comment    Go To    http://192.168.90.170/purchase/create/0
    Wait Until Element Is Visible    ${locator_create_dop_zak}    8
    Click Element    ${locator_create_dop_zak}

Поиск тендера по идентификатору
    Go To    https://192.168.90.90:448
    Input Text    ${locator_search}    UA-2017-03-14-000099
    Wait Until Element Is Enabled    ${locator_search-btn}
    Click Element    ${locator_search-btn}
    ${tender_id}=    ${id}
