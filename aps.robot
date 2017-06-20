*** Settings ***
Library           String
Library           Collections
Library           Selenium2Library
Resource          ../../op_robot_tests/tests_files/keywords.robot
Resource          ../../op_robot_tests/tests_files/resource.robot
Resource          Locators.robot
Library           DateTime
Library           conv_timeDate.py
Resource          aps_keywords.robot
Resource          view.robot

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
    Set Window Size    @{user.size}
    Run Keyword If    '${role}'!='viewer'    Login    ${user}

aps.Підготувати дані для оголошення тендера
    [Arguments]    ${username}    @{arguments}
    [Documentation]    Змінює деякі поля в tender_data (автоматично згенерованих даних для оголошення тендера) згідно з особливостями майданчика
    #замена названия компании
    ${tender_data}=    Set Variable    ${arguments[0]}
    Set To Dictionary    ${tender_data.data.procuringEntity}    name    Апс солюшн
    Set To Dictionary    ${tender_data.data.procuringEntity.identifier}    legalName    Апс солюшн
    Set To Dictionary    ${tender_data.data.procuringEntity.address}    region    мун. Кишинeв
    Set To Dictionary    ${tender_data.data.procuringEntity.address}    countryName    Молдова, Республіка
    Set To Dictionary    ${tender_data.data.procuringEntity.address}    locality    Кишинeв
    Set To Dictionary    ${tender_data.data.procuringEntity.address}    streetAddress    bvhgfhjhgj
    Set To Dictionary    ${tender_data.data.procuringEntity.address}    postalCode    23455
    Set To Dictionary    ${tender_data.data.procuringEntity.contactPoint}    name    QA #1
    Set To Dictionary    ${tender_data.data.procuringEntity.contactPoint}    telephone    0723344432
    Set To Dictionary    ${tender_data.data.procuringEntity.contactPoint}    url    http://www.pcenter.org.ua
    Set To Dictionary    ${tender_data.data.procuringEntity.identifier}    id    12345636
    ${items}=    Get From Dictionary    ${tender_data.data}    items
    ${item}=    Get From List    ${items}    0
    : FOR    ${en}    IN    @{items}
    \    Set To Dictionary    ${en.deliveryAddress}    region    м. Київ
    Set List Value    ${items}    0    ${item}
    Set To Dictionary    ${tender_data.data}    items    ${items}
    Comment    Set To Dictionary    ${tender_data.features.enum}    title_en    flower
    Return From Keyword    ${tender_data}
    [Return]    ${tender_data}

aps.Створити тендер
    [Arguments]    ${role}    ${tender_data}
    [Documentation]    Створює однопредметний тендер
    Log To Console    MODE=${MODE}
    Run Keyword And Return If    '${MODE}'=='belowThreshold'    Допороговый однопредметный тендер    ${tender_data}
    Run Keyword And Return If    '${MODE}'=='openeu'    Открытые торги с публикацией на англ    ${tender_data}
    Run Keyword And Return If    '${MODE}'=='openua'    Открытые торги с публикацией на укр    ${tender_data}
    Run Keyword And Return If    '${MODE}'=='negotiation'    Переговорная мультилотовая процедура    ${tender_data}
    Run Keyword And Return If    '${MODE}'=='Tests Files.singleItemTenderComplaints'    Работа с жалобами    ${tender_data}
    [Return]    ${UAID}

aps.Внести зміни в тендер
    [Arguments]    ${username}    ${tender_uaid}    ${field_name}    ${field_value}
    [Documentation]    Змінює значення поля field_name на field_value в тендері tender_uaid
    aps.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}

Завантажити документ
    [Arguments]    ${username}    ${filepath}    ${tender_uaid}
    [Documentation]    Завантажує супроводжуючий тендерний документ в тендер tender_uaid. Тут аргумент filepath – це шлях до файлу на диску
    Go To    ${USERS.users['${username}'].homepage}
    Search tender    ${username}    ${tender_uaid}
    Comment    Log To Console    var test=angular.element(document.getElementById(\'header\')).scope(); return test.$$childHead.purchaseId;
    Comment    sleep    10
    Comment    ${id}=    Execute Javascript    var test=angular.element(document.getElementById(\'header\')).scope(); test.$$childHead.purchaseId;
    ${id}=    Get Location
    ${id}=    Fetch From Right    ${id}    /
    Go To    ${USERS.users['${username}'].homepage}/Purchase/Edit/${id}
    Comment    Wait Until Page Contains Element    s
    Comment    Wait Until Element Is Enabled    ${locator_btn_edit_tender}
    Comment    Click Button    ${locator_btn_edit_tender}
    Load document    ${filepath}

aps.Пошук тендера по ідентифікатору
    [Arguments]    ${username}    ${tender_uaid}
    [Documentation]    Знаходить тендер по його UAID, відкриває його сторінку
    Go To    ${USERS.users['${username}'].homepage}
    Search tender    ${username}    ${tender_uaid}

Оновити сторінку з тендером
    [Arguments]    ${username}    ${tender_uaid}
    [Documentation]    Оновлює інформацію на сторінці, якщо відкрита сторінка з тендером, інакше переходить на сторінку з тендером tender_uaid
    Reload Page

aps.Отримати інформацію із тендера
    [Arguments]    ${username}    @{arguments}
    [Documentation]    Return значення поля field_name, яке бачить користувач username
    Prepare View    ${username}    ${arguments[0]}
    Run Keyword And Return If    '${arguments[1]}'=='value.amount'    Get Field Amount    xpath=.//*[@id='purchaseBudget']
    Run Keyword And Return If    '${arguments[1]}'=='tenderPeriod.startDate'    Get Field tenderPeriod.startDate
    Run Keyword And Return If    '${arguments[1]}'=='tenderPeriod.endDate'    Get Field tenderPeriod.endDate
    [Return]    field_value

Задати питання
    [Arguments]    ${username}    ${tender_uaid}    ${question}
    [Documentation]    Задає питання question від імені користувача username в тендері tender_uaid
    Search tender    ${username}    ${tender_uaid}
    Wait Until Element Is Enabled    ${locator_questions}
    Click Element    ${locator_questions}
    Click Button    ${locator_add_discussion}
    Add question    ${question}

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

aps.Отримати дані із тендера
    [Arguments]    ${username}    @{arguments}

aps.Створити постачальника, додати документацію і підтвердити його
    [Arguments]    @{arguments}
    ${supplier}=    Get From List    ${arguments}    2
    ${username}=    Get From List    ${arguments}    0
    ${filepath}=    Get From List    ${arguments}    3
    ${ua_id}=    Get From List    ${arguments}    1
    Go To    ${USERS.users['${username}'].homepage}
    Search tender    ${username}    ${ua_id}
    ${id}=    Get Location
    ${id}=    Fetch From Right    ${id}    /
    Go To    ${USERS.users['${username}'].homepage}/Purchase/Edit/${id}
    Comment    Wait Until Page Contains Element    ${locator_btn_edit_tender}
    Comment    Wait Until Element Is Enabled    ${locator_btn_edit_tender}
    Comment    Click Button    ${locator_btn_edit_tender}
    Wait Until Element Is Enabled    ${locator_participant}
    Click Element    ${locator_participant}
    Wait Until Page Contains Element    ${locator_add_participant}
    Wait Until Element Is Enabled    ${locator_add_participant}
    Click Element    ${locator_add_participant}
    ${data}=    Get From Dictionary    ${arguments}    1
    ${suppl}=    Get From Dictionary    ${data}    suppliers
    ${data}=    Get From List    ${suppl}    0
    #Цена предложения
    ${amount}=    Get From Dictionary    ${data.value}    amount
    Press Key    ${locator_amount}    ${amount}
    #Выбрать участника
    Click Element    ${locator_check_participant}
    #Код
    ${code_edrpou}=    Get From Dictionary    ${suppl.identifier}    id
    Press Key    ${locator_code_edrpou}    ${code_edrpou}
    #Нац реестр
    ${reestr}=    Get From Dictionary    ${suppl.identifier}    scheme
    Select From List By Value    ${locator_reestr}    UA-EDR
    Press Key    ${locator_reestr}    ${reestr}
    #Наименование участника (legalName)
    ${legalName}=    Get From Dictionary    ${suppl.identifier}    legalName
    Press Key    ${locator_legalName}    ${legalName}

aps.Отримати інформацію із предмету
    [Arguments]    ${username}    @{arguments}
    Prepare View    ${username}    ${arguments[0]}
    Wait Until Element Is Enabled    id=procurement-subject-tab
    Click Element    id=procurement-subject-tab
    Wait Until Element Is Enabled    id=procurement-subject
    Run Keyword And Return If    '${arguments[2]}'=='description'    Get Field item.description    ${arguments[1]}

aps.Отримати інформацію із лоту
    [Arguments]    ${username}    @{arguments}
    Prepare View    ${username}    ${arguments[0]}
    Wait Until Element Is Enabled    id=view-lots-tab
    Click Element    id=view-lots-tab
    Wait Until Element Is Enabled    id=view-lots
    Run Keyword And Return If    '${arguments[2]}'=='title'    Get Field Text    xpath=//h4[@id='Lot-1-Title'][contains(.,'${arguments[1]}')]
    Run Keyword And Return If    '${arguments[2]}'=='value.amount'    Get Field Amount    id=Lot-1-Budget
    Run Keyword And Return If    '${arguments[2]}'=='minimalStep.amount'    Get Field Amount    id=Lot-1-MinStep

aps.Отримати інформацію із нецінового показника
    [Arguments]    ${username}    @{arguments}
    Prepare View    ${username}    ${arguments[0]}
    Wait Until Element Is Enabled    id=features-tab
    Click Element    id=features-tab
    Wait Until Element Is Enabled    id=features
    Execute Javascript    window.scroll(0, 1000)
    ${d}=    Set Variable    ${arguments[1]}
    Run Keyword And Return If    '${arguments[2]}'=='title'    Get Field Text    xpath=//form[contains(@id,'updateOrCreateFeature')]//div[contains(text(),'${d}')]
