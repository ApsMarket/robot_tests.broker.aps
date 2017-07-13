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
${log_enabled}    ${EMPTY}
${start_date}     ${EMPTY}

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
    Set Suite Variable    ${log_enabled}    ${False}
    #замена названия компании
    ${tender_data}=    Set Variable    ${arguments[0]}
    Set To Dictionary    ${tender_data.data.procuringEntity}    name=Апс солюшн
    Set To Dictionary    ${tender_data.data.procuringEntity.identifier}    legalName=Апс солюшн    id=12345636
    Set To Dictionary    ${tender_data.data.procuringEntity.address}    region=мун. Кишинeв    countryName=Молдова, Республіка    locality=Кишинeв    streetAddress=bvhgfhjhgj    postalCode=23455
    Set To Dictionary    ${tender_data.data.procuringEntity.contactPoint}    name=QA #1    telephone=0723344432    url=https://dfgsdfadfg.com
    ${items}=    Get From Dictionary    ${tender_data.data}    items
    ${item}=    Get From List    ${items}    0
    : FOR    ${en}    IN    @{items}
    \    Comment    Set To Dictionary    ${en.deliveryAddress}    region    м. Київ
    \    ${is_dkpp}=    Run Keyword And Ignore Error    Dictionary Should Contain Key    ${en}    additionalClassifications
    \    Run Keyword If    ('${is_dkpp[0]}'=='PASS')    Log To Console    ${en.additionalClassifications[0].id}
    \    Run Keyword If    ('${is_dkpp[0]}'=='PASS')    Set To Dictionary    ${en.additionalClassifications[0]}    id=7242    description=Монтажники електронного устаткування
    \    ...    scheme=ДК003
    Set List Value    ${items}    0    ${item}
    Set To Dictionary    ${tender_data.data}    items    ${items}
    Return From Keyword    ${tender_data}
    [Return]    ${tender_data}

aps.Створити тендер
    [Arguments]    ${role}    ${tender_data}
    [Documentation]    Створює однопредметний тендер
    Run Keyword If    ${log_enabled}    Log To Console    MODE=${MODE}
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
    Full Click    id=purchaseEdit
    Wait Until Page Contains Element    id=save_changes
    Run Keyword If    '${field_name}'=='tenderPeriod.endDate'    Set Field tenderPeriod.endDate    ${field_value}
    Run Keyword If    '${field_name}'=='description'    Set Field Text    id=description    ${field_value}
    Full Click    id=save_changes
    Full Click    id=movePurchaseView
    Run Keyword If    '${MODE}'=='negotiation'    Publish tender/negotiation
    Run Keyword If    '${MODE}'!='negotiation'    Publish tender

aps.Завантажити документ
    [Arguments]    ${username}    ${filepath}    ${tender_uaid}
    [Documentation]    Завантажує супроводжуючий тендерний документ в тендер tender_uaid. Тут аргумент filepath – це шлях до файлу на диску
    Go To    ${USERS.users['${username}'].homepage}
    Search tender    ${username}    ${tender_uaid}
    ${idd}=    Get Location
    ${idd}=    Fetch From Left    ${idd}    \#/info-purchase
    Log To Console    ${idd}
    ${id}=    Fetch From Right    ${idd}    /
    Log To Console    ${id}
    Go To    ${USERS.users['${username}'].homepage}/Purchase/Edit/${id}#/info-purchase
    Comment    Full Click    id=purchaseEdit
    Load document    ${filepath}    Tender    ${EMPTY}
    Full Click    ${locator_finish_edit}
    Run Keyword If    '${MODE}'=='negotiation'    Publish tender/negotiation
    Run Keyword If    '${MODE}'!='negotiation'    Publish tender

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
    Run Keyword And Return If    '${arguments[1]}'=='tenderPeriod.startDate'    Get Field Date    id=purchasePeriodTenderStart
    Run Keyword And Return If    '${arguments[1]}'=='tenderPeriod.endDate'    Get Field Date    id=purchasePeriodTenderEnd
    Run Keyword And Return If    '${arguments[1]}'=='tenderID'    Get Field Text    id=purchaseProzorroId
    Run Keyword And Return If    '${arguments[1]}'=='description'    Get Field Text    xpath=.//*[@id='purchse-controller']/div/div[1]/div[1]/div/p[1]
    Run Keyword And Return If    '${arguments[1]}'=='enquiryPeriod.startDate'    Get Field Date    id=purchasePeriodEnquiryStart
    Run Keyword And Return If    '${arguments[1]}'=='enquiryPeriod.endDate'    Get Field Date    id=purchasePeriodEnquiryEnd
    Run Keyword And Return If    '${arguments[1]}'=='title'    Get Field Text    id=purchaseTitle
    Run Keyword And Return If    '${arguments[1]}'=='value.valueAddedTaxIncluded'    View.Conv to Boolean    xpath=.//*[@ng-if='purchase.purchase.isVAT']
    Run Keyword And Return If    '${arguments[1]}'=='value.valueAddedTaxIncluded'    Get Element Attribute    ${locator_purchaseIsVAT_viewer}
    Run Keyword And Return If    '${arguments[1]}'=='causeDescription'    Get Field Text    id=purchaseDirectoryCauseDescription
    Run Keyword And Return If    '${arguments[1]}'=='cause'    Get Field Text    ${locator_purchaseCauseDescr}
    Run Keyword And Return If    '${arguments[1]}'=='value.currency'    Get Field Text    ${locator_purchaseCurrency_viewer}
    Run Keyword And Return If    '${arguments[1]}'=='procuringEntity.address.countryName'    Get Field Text    ${locator_purchaseAddressCountryName_viewer}
    Run Keyword And Return If    '${arguments[1]}'=='procuringEntity.address.locality'    Get Field Text    ${locator_purchaseAddressLocality_viewer}
    Run Keyword And Return If    '${arguments[1]}'=='features[0].title'    Get Field feature.title    0_0
    Run Keyword And Return If    '${arguments[1]}'=='features[1].title'    Get Field feature.title    1_0
    Run Keyword And Return If    '${arguments[1]}'=='features[2].title'    Get Field feature.title    1_1
    Run Keyword And Return If    '${arguments[1]}'=='features[3].title'    Log To Console    333333
    Run Keyword And Return If    '${arguments[1]}'=='features[3].title'    Get Field feature.title    1_2
    Run Keyword And Return If    '${arguments[1]}'=='items[1].classification.scheme'    Get Field Text    id=procurementSubjectCpvTitle_0_0
    Run Keyword And Return If    '${arguments[1]}'=='items[1].description'    Get Field Text    id=procurementSubjectDescription_0_0
    Comment    Run Keyword And Return If    '${arguments[1]}'=='awards[0].documents[0].title'    Get Field Text
    Run Keyword And Return If    '${arguments[1]}'=='description'    Get Field Text    id=purchaseDescription
    Run Keyword And Return If    '${arguments[1]}'=='status'    Get Tender Status
    [Return]    ${field_value}

aps.Задати запитання на тендер
    [Arguments]    ${username}    ${tender_uaid}    ${question}
    [Documentation]    Задає питання question від імені користувача username в тендері tender_uaid
    Go To    ${USERS.users['${username}'].homepage}
    Search tender    ${username}    ${tender_uaid}
    Full Click    id=questions-tab
    Full Click    id=add_discussion
    Wait Until Page Contains Element    id=confirm_creationForm
    Select From List By Value    name=OfOptions    0
    Input Text    name=Title    ${question.data.title}
    Input Text    name=Description    ${question.data.description}
    Full Click    id=confirm_creationForm

Відповісти на питання
    [Arguments]    ${username}    ${tender_uaid}    ${question}    ${answer_data}    ${question_id}
    [Documentation]    [Documentation] Відповідає на запитання question з ID question_id в тендері tender_uaid відповіддю answer_data

aps.Подати цінову пропозицію
    [Arguments]    ${username}    ${tender_uaid}    ${bid}    ${x1}    ${x2}
    [Documentation]    Створює нову ставку в тендері tender_uaid
    aps.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
    Full Click    id=do-proposition-tab
    Wait Until Element Is Enabled    xpath=.//*[@id='bidlots']/div/div
    Click Element    xpath=.//*[@id='bidlots']/div/div
    Wait Until Element Is Enabled    ${locator_newProp_amount}
    Input Text    ${locator_newProp_amount}    66557
    Click Element    id=isSelfQualified_
    Wait Until Element Is Visible    id=isSelfEligible_
    Click Element    id=isSelfEligible_

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
    ${idd}=    Get Location
    ${idd}=    Fetch From Left    ${idd}    \#/info-purchase
    ${id}=    Fetch From Right    ${idd}    /
    Go To    ${USERS.users['${username}'].homepage}/Purchase/Edit/${id}#/info-purchase
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
    Click Element    ${locator_awardEligible}
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
    Run Keyword And Ignore Error    Wait Until Page Does Not Contain    Учасник Збережена успішно
    Comment    Wait Until Page Contains Element    id=uploadFile247
    Wait Until Element Is Enabled    xpath=.//input[contains(@id,'uploadFile')]
    sleep    10
    Choose File    xpath=.//input[contains(@id,'uploadFile')]    ${filepath}
    Select From List By Index    xpath=.//*[@class='form-control b-l-none ng-pristine ng-untouched ng-valid ng-empty'][contains(@id,'fileCategory')]    1
    Full Click    xpath=.//*[@class='btn btn-success'][contains(@id,'submitUpload')]
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
    sleep    2
    Wait Until Element Is Enabled    id=features-tab
    Click Element    id=features-tab
    Wait Until Element Is Enabled    id=features
    Comment    Click Element    id=features
    Execute Javascript    window.scroll(0, 500)
    ${d}=    Set Variable    ${arguments[1]}
    Wait Until Page Contains Element    id = updateOrCreateFeature_0_0    30
    Wait Until Element Is Enabled    id = updateOrCreateFeature_0_0    30
    Run Keyword And Return If    '${arguments[2]}'=='title'    Get Field Text    xpath=//form[contains(@id,'updateOrCreateFeature')]//div[contains(text(),'${d}')]

aps.Завантажити документ в лот
    [Arguments]    ${username}    ${file}    ${ua_id}    ${lot_id}
    Go To    ${USERS.users['${username}'].homepage}
    Search tender    ${username}    ${ua_id}
    Full Click    id=purchaseEdit
    Load document    ${file}    Lot    ${lot_id}
    Full Click    id=movePurchaseView
    Publish tender

aps.Змінити лот
    [Arguments]    ${username}    ${ua_id}    ${lot_id}    ${field_name}    ${field_value}
    Close All Browsers
    aps.Підготувати клієнт для користувача    ${username}
    aps.Пошук тендера по ідентифікатору    ${username}    ${ua_id}
    Full Click    id=purchaseEdit
    Wait Until Page Contains Element    id=save_changes
    Full Click    id=lots-tab
    Full Click    xpath=//h4[contains(text(),'${lot_id}')]/../../div/a/i[@class='fa fa-pencil']/..
    Run Keyword If    '${field_name}'=='value.amount'    Set Field    id=lotBudget_1    ${field_value}
    Full Click    xpath=.//*[@id='divLotControllerEdit']//button[@class='btn btn-success']
    Full Click    id=basicInfo-tab
    Full Click    id=save_changes
    Full Click    id=movePurchaseView
    Publish tender

aps.Додати неціновий показник на предмет
    [Arguments]    ${username}    @{arguments}
    aps.Пошук тендера по ідентифікатору    ${username}    ${arguments[0]}
    Full Click    id=purchaseEdit
    Wait Until Page Contains Element    id=save_changes
    Full Click    id=features-tab
    ${fi}=    Set Variable    ${arguments[1]}
    ${fi.item_id}=    Set Variable    ${arguments[2]}
    Add Feature    ${fi}    1    0
    Full Click    id=basicInfo-tab
    Full Click    id=save_changes
    Full Click    id=movePurchaseView
    Publish tender

aps.Видалити неціновий показник
    [Arguments]    ${username}    @{arguments}
    aps.Пошук тендера по ідентифікатору    ${username}    ${arguments[0]}
    Full Click    id=purchaseEdit
    Wait Until Page Contains Element    id=save_changes
    Full Click    id=features-tab
    Full Click    xpath=//div[contains(text(),'${arguments[1]}')]/../..//a[contains(@id,'updateOrCreateFeatureDeleteButton')]
    Full Click    xpath=//div[@class='jconfirm-buttons']/button[1]
    Full Click    id=basicInfo-tab
    Full Click    id=save_changes
    Full Click    id=movePurchaseView
    Publish tender

aps.Створити вимогу про виправлення умов закупівлі
    [Arguments]    ${username}    @{arguments}
    Full Click    id=claim-tab
    Wait Until Element Is Enabled    id=add_claim
    Full Click    id=add_claim
    Comment    ${data}=    Get From Dictionary    ${arguments[0]}    data
    Log To Console    ${arguments[1]}
    Execute Javascript    var model=angular.element(document.getElementById('save-claim')).scope(); \ model.newElement={ title:${data.title}, description:${data.description}, of:{ \ \ id:0 \ \ name:"Tender", \ \ valueName:"Tender" } } $('#claim_title').val(${data.title}); $('#claim_descriptions').text(${data.descriptions}); $('#add_claim_select_type').click(); \ $("#add_claim_select_type option[value='0']").attr("selected", "selected");
    Comment    Full Click    $('save-claim').click();

aps.Отримати інформацію із запитання
    [Arguments]    ${username}    @{arguments}
    aps.Пошук тендера по ідентифікатору    ${username}    ${arguments[0]}
    ${guid}=    Get Text    id=purchaseGuid
    ${api}=    Fetch From Left    ${USERS.users['${username}'].homepage}    :90
    Execute Javascript    $.get('${api}:92/api/sync/purchases/${guid}');
    ${guid}=    Get Field question.title    ${arguments[1]}
    Return From Keyword    ${guid}

aps.Підтвердити підписання контракту

aps.Відповісти на запитання
    [Arguments]    ${username}    @{arguments}
    aps.Пошук тендера по ідентифікатору    ${username}    ${arguments[0]}
    ${guid}=    Get Text    id=purchaseGuid
    ${api}=    Fetch From Left    ${USERS.users['${username}'].homepage}    :90
    Execute Javascript    $.get('${api}:92/api/sync/purchases/${guid}');
    Full Click    id=questions-tab
    Wait Until Page Contains    ${arguments[2]}
    Full Click    xpath=//div[contains(text(),'${arguments[2]}')]/../../../..//button[@id='reply_answer']
    Full Click    xpath=//textarea[@ng-model='element.answer']
    Input Text    xpath=//textarea[@ng-model='element.answer']    ${arguments[1].data.answer}
    Full Click    xpath=//div[contains(text(),'${arguments[2]}')]/../../../..//button[@id='save_answer']
    Publish tender
    Return From Keyword    ${guid}
