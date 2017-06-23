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
    Open Browser    ${user.homepage}    ${user.browser}    desired_capabilities=nativeEvents:false
    Set Window Position    @{user.position}
    Set Window Size    @{user.size}
    Run Keyword If    '${role}'!='viewer'    Login    ${user}

aps.Підготувати дані для оголошення тендера
    [Arguments]    ${username}    @{arguments}
    [Documentation]    Змінює деякі поля в tender_data (автоматично згенерованих даних для оголошення тендера) згідно з особливостями майданчика
    #замена названия компании
    ${tender_data}=    Set Variable    ${arguments[0]}
    Log To Console    111111
    Log To Console    ${arguments}
    Log To Console    22222
    Set To Dictionary    ${tender_data.data.procuringEntity}    name    Апс солюшн
    Set To Dictionary    ${tender_data.data.procuringEntity.identifier}    legalName=Апс солюшн    id=12345636
    Set To Dictionary    ${tender_data.data.procuringEntity.address}    region=мун. Кишинeв    countryName=Молдова, Республіка    locality=Кишинeв    streetAddress=bvhgfhjhgj    postalCode=23455
    Set To Dictionary    ${tender_data.data.procuringEntity.contactPoint}    name=QA #1    telephone=0723344432    url=https://dfgsdfadfg.com
    ${items}=    Get From Dictionary    ${tender_data.data}    items
    ${item}=    Get From List    ${items}    0
    : FOR    ${en}    IN    @{items}
    \    Comment    Set To Dictionary    ${en.deliveryAddress}    region    м. Київ
    \    ${is_dkpp}=    Run Keyword And Ignore Error    Dictionary Should Contain Key    ${en}    additionalClassifications
    \    Run Keyword If    ('${is_dkpp[0]}'=='PASS')    Run Keyword If    '${en.additionalClassifications[0].id}'=='7242.1'    Set To Dictionary    ${en.additionalClassifications.id}
    \    ...    7242
    \    Run Keyword If    ('${is_dkpp[0]}'=='PASS')    Run Keyword If    '${en.additionalClassifications[0].id}'=='17.12.77-80.00'    Set To Dictionary    ${en.additionalClassifications.id}
    \    ...    17.12
    \    Comment
    Set List Value    ${items}    0    ${item}
    Set To Dictionary    ${tender_data.data}    items    ${items}
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
    Comment    Wait Until Page Contains Element    id=purchaseEdit
    Comment    Click Button    id=purchaseEdit
    ${id}=    Get Location
    ${id}=    Fetch From Right    ${id}    /
    Go To    ${USERS.users['${username}'].homepage}/Purchase/Edit/${id}
    Wait Until Page Contains Element    id=save_changes
    Run Keyword If    '${field_name}'=='tenderPeriod.endDate'    Set Field tenderPeriod.endDate    ${field_value}
    Wait Until Element Is Enabled    id=save_changes    50
    Click Button    id=save_changes
    Wait Until Element Is Enabled    id=movePurchaseView
    Run Keyword And Ignore Error    Wait Until Element Is Not Visible    xpath=.//div[@class='page-loader animated fadeIn']
    Click Button    id=movePurchaseView
    Wait Until Element Is Enabled    id=publishPurchase
    Click Button    id=publishPurchase
    sleep    2

aps.Завантажити документ
    [Arguments]    ${username}    ${filepath}    ${tender_uaid}
    [Documentation]    Завантажує супроводжуючий тендерний документ в тендер tender_uaid. Тут аргумент filepath – це шлях до файлу на диску
    Go To    ${USERS.users['${username}'].homepage}
    Search tender    ${username}    ${tender_uaid}
    ${id}=    Get Location
    ${id}=    Fetch From Right    ${id}    /
    Go To    ${USERS.users['${username}'].homepage}/Purchase/Edit/${id}
    Load document    ${filepath}    Tender    ${EMPTY}
    Publish tender

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
    Run Keyword And Return If    '${arguments[1]}'=='tenderID'    Get Field Text
    Run Keyword And Return If    '${arguments[1]}'=='description'    Get Field Text
    Run Keyword And Return If    '${arguments[1]}'=='tenderPeriod.startDate'    Get Field Date    id=purchasePeriodTenderStart
    Run Keyword And Return If    '${arguments[1]}'=='tenderPeriod.endDate'    Get Field Date    id=purchasePeriodTenderEnd
    Run Keyword And Return If    '${arguments[1]}'=='enquiryPeriod.startDate'    Get Field Date    id=purchasePeriodEnquiryStart
    Run Keyword And Return If    '${arguments[1]}'=='enquiryPeriod.endDate'    Get Field Date    id=purchasePeriodEnquiryEnd
    Run Keyword And Return If    '${arguments[1]}'=='features[0].title'    Get Field feature.title    ${arguments[1]}
    [Return]    ${field_value}

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
    Log To Console    отримати дані із тендера в

aps.Створити постачальника, додати документацію і підтвердити його
    [Arguments]    ${username}    ${ua_id}    ${s}    ${filepath}
    Comment    ${supplier}=    Get From List    ${arguments}    2
    Comment    ${username}=    Get From List    ${arguments}    0
    Comment    ${filepath}=    Get From List    ${arguments}    3
    Comment    ${ua_id}=    Get From List    ${arguments}    1
    Comment    ${username}=    Set Variable    aps_Owner
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
    #Цена предложения
    ${amount}=    Get From Dictionary    ${s.data.value}    amount
    Wait Until Page Contains Element    ${locator_amount}
    Wait Until Element Is Enabled    ${locator_amount}
    Input Text    ${locator_amount}    ${amount}
    #Выбрать участника
    Click Element    ${locator_check_participant}
    #Код
    ${sup}=    Get From List    ${s.data.suppliers}    0
    ${code_edrpou}=    Get From Dictionary    ${sup.identifier}    id
    Wait Until Page Contains Element    ${locator_code_edrpou}
    Wait Until Element Is Enabled    ${locator_code_edrpou}
    Press Key    ${locator_code_edrpou}    ${sup.identifier.id}
    #Нац реестр
    ${reestr}=    Get From Dictionary    ${sup.identifier}    scheme
    Select From List By Value    ${locator_reestr}    UA-EDR
    Press Key    ${locator_reestr}    ${reestr}
    #Наименование участника (legalName)
    ${legalName}=    Get From Dictionary    ${sup.identifier}    legalName
    Press Key    ${locator_legalName}    ${legalName}
    #Выбор страны
    ${country}=    Get From Dictionary    ${sup.address}    countryName
    Select From List By Label    ${locator_country_id}    ${country}
    #Выбор региона
    ${region}=    Get From Dictionary    ${sup.address}    region
    Execute Javascript    var autotestmodel=angular.element(document.getElementById('procuringParticipantLegalName_0_0')).scope(); autotestmodel.procuringParticipant.procuringParticipants.region=autotestmodel.procuringParticipant.procuringParticipants.country; autotestmodel.procuringParticipant.procuringParticipants.region={id:0,name:'${region}',initName:'${region}'};
    Execute Javascript    window.scroll(1000, 1000)
    #Индекс
    ${post_code}=    Get From Dictionary    ${sup.address}    postalCode
    Press Key    ${locator_post_code}    ${post_code}
    #Насел пункт
    ${locality}=    Get From Dictionary    ${sup.address}    locality
    Press Key    ${locator_local}    ${locality}
    #Адрес
    ${street}=    Get From Dictionary    ${sup.address}    streetAddress
    Press Key    ${locator_street_ng}    ${street}
    #ФИО
    ${name}=    Get From Dictionary    ${sup.contactPoint}    name
    Press Key    ${locator_name}    ${name}
    #e-mail
    ${mail}=    Get From Dictionary    ${sup.contactPoint}    email
    Press Key    ${locator_mail_ng}    ${mail}
    #Телефон
    ${phone}=    Get From Dictionary    ${sup.contactPoint}    telephone
    Press Key    ${locator_phone_ng}    ${phone}
    #Click but
    Wait Until Element Is Visible    ${locator_save_participant}
    Click Button    ${locator_save_participant}
    #Add doc
    Wait Until Page Contains Element    ${locator_add_doc_ng}
    sleep    10
    Choose File    ${locator_add_doc_ng}    ${filepath}
    #save
    Wait Until Page Contains Element    ${locator_finish_edit}
    Click Button    ${locator_finish_edit}
    #publish
    Publish tender/negotiation

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
    Click Element    id=features
    Execute Javascript    window.scroll(0, 2000)
    ${d}=    Set Variable    ${arguments[1]}
    Wait Until Page Contains Element    id = updateOrCreateFeature_0_0    30
    Wait Until Element Is Enabled    id = updateOrCreateFeature_0_0    30
    Run Keyword And Return If    '${arguments[2]}'=='title'    Get Field Text    xpath=//form[contains(@id,'updateOrCreateFeature')]//div[contains(text(),'${d}')]

aps.Завантажити документ в лот
    [Arguments]    ${username}    ${file}    ${ua_id}    ${lot_id}
    Go To    ${USERS.users['${username}'].homepage}
    Search tender    ${username}    ${ua_id}
    ${id}=    Get Location
    ${id}=    Fetch From Right    ${id}    /
    Go To    ${USERS.users['${username}'].homepage}/Purchase/Edit/${id}
    Load document    ${file}    Lot    ${lot_id}
    Publish tender

aps.Змінити лот
    [Arguments]    ${username}    ${ua_id}    ${lot_id}    ${field_name}    ${field_value}
    aps.Пошук тендера по ідентифікатору    ${username}    ${ua_id}
    ${id}=    Get Location
    ${id}=    Fetch From Right    ${id}    /
    Go To    ${USERS.users['${username}'].homepage}/Purchase/Edit/${id}
    Wait Until Page Contains Element    id=save_changes
    Click Element    id=lots-tab
    Wait Until Page Contains Element    xpath=//h4[contains(text(),'${lot_id}')]/../../div/a/i[@class='fa fa-pencil']/..
    Click Element    xpath=//h4[contains(text(),'${lot_id}')]/../../div/a/i[@class='fa fa-pencil']/..
    sleep    500
    Run Keyword If    '${field_name}'=='tenderPeriod.endDate'    Set Field tenderPeriod.endDate    ${field_value}
