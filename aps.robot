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
    Comment    Open Browser    ${user.homepage}    ${user.browser}    desired_capabilities=nativeEvents:false
    ${chrome options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    ${prefs}    Create Dictionary    prompt_for_download=false    download.default_directory=${OUTPUT_DIR}    download.directory_update=True
    Call Method    ${chrome options}    add_experimental_option    prefs    ${prefs}
    Create Webdriver    Chrome    chrome_options=${chrome options}
    Goto    ${user.homepage}
    Set Window Position    @{user.position}
    Set Window Size    @{user.size}
    Run Keyword If    '${role}'!='viewer'    Login    ${user}

aps.Підготувати дані для оголошення тендера
    [Arguments]    ${username}    @{arguments}
    [Documentation]    Змінює деякі поля в tender_data (автоматично згенерованих даних для оголошення тендера) згідно з особливостями майданчика
    Set Suite Variable    ${log_enabled}    ${False}
    #замена названия компании
    ${tender_data}=    Set Variable    ${arguments[0]}
    Run Keyword If    '${role}'!='viewer'    Set To Dictionary    ${tender_data.data.procuringEntity}    name=Апс солюшн
    Run Keyword If    '${role}'=='viewer'    Set To Dictionary    ${tender_data.data.procuringEntity}    name=Апс солюшн
    Comment    Set To Dictionary    ${tender_data.data.procuringEntity}    name=Апс солюшн
    Set To Dictionary    ${tender_data.data.procuringEntity.identifier}    legalName=Апс солюшн    id=12345636
    Set To Dictionary    ${tender_data.data.procuringEntity.address}    region=мун. Кишинeв    countryName=Молдова, Республіка    locality=Кишинeв    streetAddress=bvhgfhjhgj    postalCode=785445
    Set To Dictionary    ${tender_data.data.procuringEntity.contactPoint}    name=Апс солюшн    telephone=0723344432    url=https://dfgsdfadfg.com
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
    Log To Console    MODE=${MODE}
    Log To Console    suite = ${SUITE_NAME}
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
    ${id}=    Fetch From Right    ${idd}    /
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
    ${guid}=    Get Text    id=purchaseGuid
    ${api}=    Fetch From Left    ${USERS.users['${username}'].homepage}    :90
    Load Tender    ${api}:92/api/sync/purchases/${guid}
    sleep    2

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
    Run Keyword And Return If    '${arguments[1]}'=='causeDescription'    Get Field Text    id=purchaseCauseDescription
    Run Keyword And Return If    '${arguments[1]}'=='cause'    Execute Javascript    return $('#purchaseDirectoryCauseCause').text();
    Run Keyword And Return If    '${arguments[1]}'=='value.currency'    Get Field Text    ${locator_purchaseCurrency_viewer}
    Run Keyword And Return If    '${arguments[1]}'=='procuringEntity.address.countryName'    Get Field Text    ${locator_purchaseAddressCountryName_viewer}
    Run Keyword And Return If    '${arguments[1]}'=='procuringEntity.address.locality'    Get Field Text    ${locator_purchaseAddressLocality_viewer}
    Run Keyword And Return If    '${arguments[1]}'=='features[0].title'    Get Field feature.title    0_0
    Run Keyword And Return If    '${arguments[1]}'=='features[1].title'    Get Field feature.title    1_0
    Run Keyword And Return If    '${arguments[1]}'=='features[2].title'    Get Field feature.title    1_1
    Run Keyword And Return If    '${arguments[1]}'=='features[3].title'    Get Field feature.title    1_2
    Run Keyword And Return If    '${arguments[1]}'=='items[1].classification.scheme'    Get Field Text    id=procurementSubjectCpvTitle_0_0
    Run Keyword And Return If    '${arguments[1]}'=='items[1].description'    Get Field Text    id=procurementSubjectDescription_0_0
    Run Keyword And Return If    '${arguments[1]}'=='procuringEntity.address.postalCode'    Get Field Text    id=purchaseAddressZipCode
    Run Keyword And Return If    '${arguments[1]}'=='procuringEntity.address.region'    Get Field Text    id=purchaseAddressRegion
    Run Keyword And Return If    '${arguments[1]}'=='procuringEntity.address.streetAddress'    Get Field Text    id=purchaseAddressStreet
    Run Keyword And Return If    '${arguments[1]}'=='procuringEntity.contactPoint.name'    Get Field Text    id=purchaseProcuringEntityContactPointName
    Run Keyword And Return If    '${arguments[1]}'=='procuringEntity.contactPoint.telephone'    Get Field Text    id=purchaseProcuringEntityContactPointPhone
    Run Keyword And Return If    '${arguments[1]}'=='procuringEntity.contactPoint.url'    Get Field Text    id=purchaseProcuringEntityContactPointUrl
    Run Keyword And Return If    '${arguments[1]}'=='procuringEntity.identifier.scheme'    Get Field Text    id=identifierScheme
    Run Keyword And Return If    '${arguments[1]}'=='procuringEntity.identifier.id'    Get Field Text    id=identifierCode
    Run Keyword And Return If    '${arguments[1]}'=='procuringEntity.identifier.legalName'    Get Field Text    id=identifierName
    Comment    Run Keyword And Return If    '${arguments[1]}'=='procuringEntity.name'    Get Field Text    id=purchaseProcuringEntityContactPointName
    Comment    Run Keyword And Return If    '${arguments[1]}'=='awards[0].documents[0].title'    Get Field Text
    Run Keyword And Return If    '${arguments[1]}'=='description'    Get Field Text    id=purchaseDescription
    Run Keyword And Return If    '${arguments[1]}'=='procuringEntity.name'    Get Field Text    id=purchaseProcuringEntityContactPointName
    Run Keyword And Return If    '${arguments[1]}'=='minimalStep.amount'    Get Field Amount    id=Lot-1-MinStep
    Comment    Run Keyword And Return If    '${arguments[1]}'=='lots[0].value.valueAddedTaxIncluded'    Get Field Text    id=purchaseIsVAT
    Run Keyword And Return If    '${arguments[1]}'=='status'    Get Tender Status
    Run Keyword And Return If    '${arguments[1]}'=='procuringEntity.name'    Get Field Text    id=identifierName
    Run Keyword And Return If    '${arguments[1]}'=='minimalStep.amount'    Get Field Amount    id=minStepValue
    Run Keyword And Return If    '${arguments[1]}'=='awards[0].complaintPeriod.endDate'    Get Field Date    xpath=.//*[contains(@id,'ContractComplaintPeriodEnd_')]
    Run Keyword And Return If    '${arguments[1]}'=='items[0].deliveryLocation.latitude'    Get Field Amount for latitude    xpath=.//*[@class="col-md-8 ng-binding"][contains (@id,'procurementSubjectLatitude')]
    Comment    Run Keyword And Return If    '${arguments[1]}'=='items[0].deliveryLocation.'    Get Field Amount    xpath=.//*[@class="col-md-8 ng-binding"][contains (@id,'procurementSubjectLatitude')]
    Run Keyword And Return If    '${arguments[1]}'=='documents[0].title'    Get Field Doc    id=docFileName1
    Comment    Run Keyword And Return If    '${arguments[1]}'=='awards[0].documents[0].title'
    Run Keyword And Return If    '${arguments[1]}'=='awards[0].documents[0].title'    Get Field Doc    xpath=.//*[@id='createOrUpdateProcuringParticipantNegotiation_0_0']/div/div/div[3]/div/div/div/a
    Run Keyword And Return If    '${arguments[1]}'=='awards[0].status'    Get Field Text    id=winner
    Run Keyword And Return If    '${arguments[1]}'=='awards[0].suppliers[0].address.countryName'    Get Field Text    id=procuringParticipantsAddressCountryName_0_0
    Run Keyword And Return If    '${arguments[1]}'=='awards[0].suppliers[0].address.region'    Get Field Text    id=procuringParticipantsAddressRegion_0_0
    Run Keyword And Return If    '${arguments[1]}'=='awards[0].suppliers[0].address.locality'    Get Field Text    id=procuringParticipantsAddressLocality_0_0
    Run Keyword And Return If    '${arguments[1]}'=='awards[0].suppliers[0].contactPoint.telephone'    Get Field Text    id=procuringParticipantsContactPointPhone_0_0
    Run Keyword And Return If    '${arguments[1]}'=='awards[0].suppliers[0].contactPoint.name'    Get Field Text    id=procuringParticipantsContactPointName_0_0
    Run Keyword And Return If    '${arguments[1]}'=='awards[0].suppliers[0].contactPoint.email'    Get Field Text    id=procuringParticipantsContactPointEmail_0_0
    Run Keyword And Return If    '${arguments[1]}'=='awards[0].suppliers[0].identifier.scheme'    Get Field Text    id=procuringParticipantsIdentifierScheme_0_0
    Run Keyword And Return If    '${arguments[1]}'=='awards[0].suppliers[0].identifier.legalName'    Get Field Text    id=procuringParticipantsIdentifierLegalName_0_0
    Run Keyword And Return If    '${arguments[1]}'=='awards[0].suppliers[0].identifier.id'    Get Field Text    id=procuringParticipantsIdentifierCode_0_0
    Run Keyword And Return If    '${arguments[1]}'=='awards[0].suppliers[0].address.postalCode'    Get Field Text    id=procuringParticipantsAddressZipCode_0_0
    Run Keyword And Return If    '${arguments[1]}'=='awards[0].suppliers[0].address.streetAddress'    Get Field Text    id=procuringParticipantsAddressStreet_0_0
    [Return]    ${field_value}

aps.Задати запитання на тендер
    [Arguments]    ${username}    ${tender_uaid}    ${question}
    [Documentation]    Задає питання question від імені користувача username в тендері tender_uaid
    Close All Browsers
    aps.Підготувати клієнт для користувача    ${username}
    Search tender    ${username}    ${tender_uaid}
    Full Click    id=questions-tab
    Full Click    id=add_discussion
    Wait Until Page Contains Element    id=confirm_creationForm
    Select From List By Value    name=OfOptions    0
    Input Text    name=Title    ${question.data.title}
    Input Text    name=Description    ${question.data.description}
    Full Click    id=confirm_creationForm

aps.Подати цінову пропозицію
    [Arguments]    ${username}    ${tender_uaid}    ${bid}    ${to_id}    ${params}
    [Documentation]    Створює нову ставку в тендері tender_uaid
    Close All Browsers
    aps.Підготувати клієнт для користувача    ${username}
    aps.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
    Full Click    id=do-proposition-tab
    ${msg}=    Run Keyword And Ignore Error    Dictionary Should Contain Key    ${bid.data}    lotValues
    Run Keyword If    '${msg[0]}'=='FAIL'    Add Bid Tender    ${bid.data.value.amount}
    Run Keyword If    '${msg[0]}'!='FAIL'    Add Bid Lot    ${bid}    ${to_id}    ${params}

aps.Змінити цінову пропозицію
    [Arguments]    ${username}    ${tender_uaid}    ${fieldname}    ${fieldvalue}
    [Documentation]    Змінює поле fieldname (сума, неціновий показник тощо) в раніше створеній ставці в тендері tender_uaid
    aps.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
    Full Click    id=do-proposition-tab
    Run Keyword And Ignore Error    Full Click    //a[contains(@id,'openLotForm')]
    Run Keyword And Ignore Error    Full Click    id=editButton
    Run Keyword And Ignore Error    Full Click    id=editLotButton_0
    Run Keyword And Return If    '${fieldname}'=='value.amount'    Set Field Amount    id=bidAmount    ${fieldvalue}
    Run Keyword And Return If    '${fieldname}'=='lotValues[0].value.amount'    Set Field Amount    id=lotAmount_0    ${fieldvalue}
    Run Keyword And Ignore Error    Full Click    id=submitBid
    Run Keyword And Ignore Error    Full Click    id=lotSubmit_0
    Run Keyword And Ignore Error    Full Click    id=publishButton

aps.Отримати дані із тендера
    [Arguments]    ${username}    @{arguments}
    Log To Console    отримати дані із тендера в

aps.Створити постачальника, додати документацію і підтвердити його
    [Arguments]    ${username}    ${ua_id}    ${s}    ${filepath}
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
    Full Click    id=procurement-subject-tab
    Wait Until Element Is Enabled    id=procurement-subject
    ${item_path}=    Set Variable    xpath=//h4[contains(@id,'procurementSubjectDescription')][contains(.,\'${arguments[1]}\')]
    Run Keyword And Return If    '${arguments[2]}'=='description'    Get Field Text    ${item_path}
    Run Keyword And Return If    '${arguments[2]}'=='deliveryDate.startDate'    Get Field Date    ${item_path}/../../..//div[contains(@id,'procurementSubjectDeliveryStart')]
    Run Keyword And Return If    '${arguments[2]}'=='deliveryDate.endDate'    Get Field Date    ${item_path}/../../..//div[contains(@id,'procurementSubjectDeliveryEnd')]
    Run Keyword And Return If    '${arguments[2]}'=='classification.scheme'    Get Field Text    ${item_path}/../../..//span[contains(@id,'procurementSubjectCpvSheme')]
    Run Keyword And Return If    '${arguments[2]}'=='classification.id'    Get Field Text    ${item_path}/../../..//span[contains(@id,'procurementSubjectCpvCode')]
    Run Keyword And Return If    '${arguments[2]}'=='classification.description'    Get Field Text    ${item_path}/../../..//span[contains(@id,'procurementSubjectCpvTitle')]
    Run Keyword And Return If    '${arguments[2]}'=='unit.name'    Get Field Text    ${item_path}/../../..//span[contains(@id,'procurementSubjectUnitName')]
    Run Keyword And Return If    '${arguments[2]}'=='unit.code'    Get Field Text    ${item_path}/../../..//span[contains(@id,'procurementSubjectUnitCode')]
    Run Keyword And Return If    '${arguments[2]}'=='quantity'    Get Field Amount    ${item_path}/../../..//span[contains(@id,'procurementSubjectQuantity')]
    Run Keyword And Return If    '${arguments[2]}'=='deliveryLocation.longitude'    Get Field Amount    ${item_path}/../../..//div[contains(@id,'procurementSubjectLongitude')]
    Run Keyword And Return If    '${arguments[2]}'=='deliveryLocation.latitude'    Get Field Amount    ${item_path}/../../..//div[contains(@id,'procurementSubjectLatitude')]
    Run Keyword And Return If    '${arguments[2]}'=='deliveryAddress.countryName'    Get Field Text    ${item_path}/../../..//div[contains(@id,'procurementSubjectCounrtyName')]
    Run Keyword And Return If    '${arguments[2]}'=='deliveryAddress.postalCode'    Get Field Text    ${item_path}/../../..//div[contains(@id,'procurementSubjectZipCode')]
    Run Keyword And Return If    '${arguments[2]}'=='deliveryAddress.region'    Get Field Text    ${item_path}/../../..//div[contains(@id,'procurementSubjectRegionName')]
    Run Keyword And Return If    '${arguments[2]}'=='deliveryAddress.locality'    Get Field Text    ${item_path}/../../..//div[contains(@id,'procurementSubjectLocality')]
    Run Keyword And Return If    '${arguments[2]}'=='deliveryAddress.streetAddress'    Get Field Text    ${item_path}/../../..//div[contains(@id,'procurementSubjectStreet')]
    Run Keyword And Return If    '${arguments[2]}'=='additionalClassifications[0].scheme'    Get Field Text    ${item_path}/../../..//span[contains(@id,'procurementSubjectOtherClassSheme')]
    Run Keyword And Return If    '${arguments[2]}'==' additionalClassifications[0].id'    Get Field Text    ${item_path}/../../..//span[contains(@id,'procurementSubjectOtherClassCode')]
    Run Keyword And Return If    '${arguments[2]}'=='additionalClassifications[0].description'    Get Field Text    ${item_path}/../../..//div[contains(@id,'procurementSubjectOtherClassTitle')]

aps.Отримати інформацію із лоту
    [Arguments]    ${username}    @{arguments}
    Prepare View    ${username}    ${arguments[0]}
    Wait Until Element Is Enabled    id=view-lots-tab
    Click Element    id=view-lots-tab
    Wait Until Element Is Enabled    id=view-lots
    Run Keyword And Return If    '${arguments[2]}'=='title'    Get Field Text    xpath=//h4[@id='Lot-1-Title'][contains(.,'${arguments[1]}')]
    Run Keyword And Return If    '${arguments[2]}'=='value.amount'    Get Field Amount    id=Lot-1-Budget
    Run Keyword And Return If    '${arguments[2]}'=='description'    Get Field Text    id=Lot-1-Description
    Run Keyword And Return If    '${arguments[2]}'=='minimalStep.amount'    Get Field Amount    id=Lot-1-MinStep
    Run Keyword And Return If    '${arguments[2]}'=='value.currency'    Get Field Text    id=Lot-1-Currency
    Run Keyword And Return If    '${arguments[2]}'=='description'    Get Field Text    id=Lot-1-Description
    Run Keyword And Return If    '${arguments[2]}'=='minimalStep.valueAddedTaxIncluded'    Get Tru PDV    purchaseIsVAT@isvat
    Run Keyword And Return If    '${arguments[2]}'=='minimalStep.currency'    Get Field Text    id=Lot-1-Currency
    Run Keyword And Return If    '${arguments[2]}'=='value.valueAddedTaxIncluded'    Get Tru PDV    purchaseIsVAT@isvat
    [Return]    ${field_value}

aps.Отримати інформацію із нецінового показника
    [Arguments]    ${username}    @{arguments}
    aps.Пошук тендера по ідентифікатору    ${username}    ${arguments[0]}
    Full Click    id=features-tab
    Wait Until Element Is Enabled    id=features
    ${d}=    Set Variable    ${arguments[1]}
    Wait Until Element Is Enabled    xpath=//div[contains(@id,'_Title')][contains(.,'${d}')]    30
    Run Keyword And Return If    '${arguments[2]}'=='title'    Get Field Text    xpath=//div[contains(@id,'_Title')][contains(.,'${d}')]
    Run Keyword And Return If    '${arguments[2]}'=='description'    Get Field Text    xpath=//div[contains(@id,'_Title')][contains(.,'${d}')]/../../../div/div/div[contains(@id,'featureDescription')]
    Run Keyword And Return If    '${arguments[2]}'=='featureOf'    Get Element Attribute    xpath=//div[contains(@id,'_Title')][contains(.,'${d}')]/../../../../../../../..@itemid

aps.Завантажити документ в лот
    [Arguments]    ${username}    ${file}    ${ua_id}    ${lot_id}
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
    Run Keyword If    '${field_name}'=='value.amount'    Set Field Amount    id=lotBudget_1    ${field_value}
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
    Comment    Full Click    id=save_changes
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
    Comment    Full Click    id=save_changes
    Full Click    id=movePurchaseView
    Publish tender

aps.Створити вимогу про виправлення умов закупівлі
    [Arguments]    ${username}    @{arguments}
    Full Click    id=claim-tab
    Wait Until Element Is Enabled    id=add_claim
    Full Click    id=add_claim
    ${data}=    Set Variable    ${arguments[1]}
    Execute Javascript    var model=angular.element(document.getElementById('save-claim')).scope(); \ model.newElement={ title:${data.title}, description:${data.description}, of:{ \ \ id:0 \ \ name:"Tender", \ \ valueName:"Tender" } } $('#claim_title').val(${data.title}); $('#claim_descriptions').text(${data.descriptions}); $('#add_claim_select_type').click(); \ $("#add_claim_select_type option[value='0']").attr("selected", "selected");
    Full Click    save_claim

aps.Отримати інформацію із запитання
    [Arguments]    ${username}    @{arguments}
    aps.Пошук тендера по ідентифікатору    ${username}    ${arguments[0]}
    Run Keyword And Return If    '${arguments[2]}'=='title'    Get Field Question    ${arguments[1]}    xpath=//div[@id='questionTitle_0'][contains(.,'${arguments[1]}')]
    Run Keyword And Return If    '${arguments[2]}'=='description'    Get Field Question    ${arguments[1]}    xpath=//div[contains(.,'${arguments[1]}')]/div/div[contains(@id,'questionDescription')]
    Run Keyword And Return If    '${arguments[2]}'=='answer'    Get Field Question    ${arguments[1]}    xpath=//div[contains(.,'${arguments[1]}')]//div[contains(@id,'questionAnswer')]

aps.Підтвердити підписання контракту
    [Arguments]    ${username}    ${command}    @{arguments}
    ${guid}=    Get Text    id=purchaseGuid
    ${api}=    Fetch From Left    ${USERS.users['${username}'].homepage}    :90
    Execute Javascript    $.get('${api}:92/api/sync/purchases/${guid}');
    Full Click    id=processing-tab
    Execute Javascript    window.scroll(1000, 1000)
    Click Button    xpath=.//*[@id='processingContract0']/div/div/div[3]/div/div[4]/div/button
    #add contract
    Full Click    id=processing-tab
    Comment    Full Click    xpath=.//*[@id='processingContract0']/div/div/div[2]/div/div/div/file-category-upload/div/div/div[1]/label
    Comment    Choose File    xpath=.//*[@id='processingContract0']/div/div/div[2]/div/div/div/file-category-upload/div/div/input    /home/ova/robot_tests/test.txt
    Wait Until Element Is Enabled    xpath=.//input[contains(@id,'uploadFile')]
    sleep    10
    Choose File    xpath=.//input[contains(@id,'uploadFile')]    /home/ova/robot_tests/test.txt
    Log To Console    1111111111
    Select From List By Index    xpath=.//*[contains(@id,'fileCategory')]    1
    Log To Console    2222222222
    Full Click    xpath=.//*[@class="btn btn-success"][contains(@id,'submitUpload')]
    Input Text    id=processingContractContractNumber    666
    Click Element    id=processingContractDateSigned
    Click Element    id=processingContractStartDate
    Click Element    id=processingContractEndDate
    Click Button    xpath=.//*[@id='processingContract0']/div/div/div[3]/div/div[4]/div/button

aps.Відповісти на запитання
    [Arguments]    ${username}    @{arguments}
    aps.Пошук тендера по ідентифікатору    ${username}    ${arguments[0]}
    Full Click    id=questions-tab
    Wait Until Page Contains    ${arguments[2]}
    Full Click    xpath=//div[contains(text(),'${arguments[2]}')]/../../../..//button[@id='reply_answer']
    Full Click    xpath=//textarea[@ng-model='element.answer']
    Input Text    xpath=//textarea[@ng-model='element.answer']    ${arguments[1].data.answer}
    Full Click    xpath=//div[contains(text(),'${arguments[2]}')]/../../../..//button[@id='save_answer']
    Publish tender

aps.Отримати інформацію із документа
    [Arguments]    ${username}    @{arguments}
    aps.Пошук тендера по ідентифікатору    ${username}    ${arguments[0]}
    Full Click    id=documents-tab
    Run Keyword And Return If    '${arguments[2]}'=='title'    Get Field Text    xpath=//a[contains(@id,'docFileName')][contains(.,'${arguments[1]}')]

aps.Отримати документ
    [Arguments]    ${username}    @{arguments}
    aps.Пошук тендера по ідентифікатору    ${username}    ${arguments[0]}
    Full Click    id=documents-tab
    ${title}=    Get Field Text    xpath=//a[contains(@id,'docFileName')][contains(.,'${arguments[1]}')]
    Full Click    xpath=//a[contains(.,'${arguments[1]}')]/../../../../..//a[contains(@id,'strikeDocFileNameBut')]
    sleep    3
    Return From Keyword    ${title}

aps.Отримати інформацію із пропозиції
    [Arguments]    ${username}    @{arguments}
    aps.Пошук тендера по ідентифікатору    ${username}    ${arguments[0]}
    Full Click    id=do-proposition-tab
    Run Keyword And Ignore Error    Full Click    id=openLotForm_0
    Run Keyword And Return If    '${arguments[1]}'=='value.amount'    Get Field Amount    id=bidAmount
    Run Keyword And Return If    '${arguments[1]}'=='lotValues[0].value.amount'    Get Field Amount    id=lotAmount_0

aps.Завантажити документ в ставку
    [Arguments]    ${username}    @{arguments}
    aps.Пошук тендера по ідентифікатору    ${username}    ${arguments[1]}
    Full Click    id=do-proposition-tab
    Run Keyword And Ignore Error    Full Click    //a[contains(@id,'openLotForm')]
    Run Keyword And Ignore Error    Full Click    id=editLotButton_0
    Run Keyword And Ignore Error    Full Click    id=editButton
    Run Keyword And Ignore Error    Full Click    id=openLotDocuments_technicalSpecifications_0
    Run Keyword And Ignore Error    Full Click    id=openDocuments_biddingDocuments
    Run Keyword And Ignore Error    Choose File    id=bidDocInput_biddingDocuments    ${arguments[0]}
    Run Keyword And Ignore Error    Choose File    bidLotDocInputBtn_technicalSpecifications_0    ${arguments[0]}
    Capture Page Screenshot
    Run Keyword And Ignore Error    Full Click    id=submitBid
    Run Keyword And Ignore Error    Full Click    id=lotSubmit_0
    Run Keyword And Ignore Error    Full Click    id=publishButton

aps.Змінити документ в ставці
    [Arguments]    ${username}    @{arguments}
    aps.Пошук тендера по ідентифікатору    ${username}    ${arguments[0]}
    Full Click    id=do-proposition-tab
    Run Keyword And Ignore Error    Full Click    //a[contains(@id,'openLotForm')]
    Run Keyword And Ignore Error    Full Click    id=editLotButton_0
    Run Keyword And Ignore Error    Full Click    id=editButton
    Run Keyword And Ignore Error    Full Click    id=openLotDocuments_technicalSpecifications_0
    Run Keyword And Ignore Error    Full Click    id=openDocuments_biddingDocuments
    Run Keyword And Ignore Error    Choose File    id=bidDocInput_biddingDocuments    ${arguments[1]}
    Run Keyword And Ignore Error    Choose File    bidLotDocInputBtn_technicalSpecifications_0    ${arguments[1]}
    Capture Page Screenshot
    Run Keyword And Ignore Error    Full Click    id=submitBid
    Run Keyword And Ignore Error    Full Click    id=lotSubmit_0
    Run Keyword And Ignore Error    Full Click    id=publishButton

aps.Отримати посилання на аукціон для учасника
    [Arguments]    ${username}    @{arguments}
    aps.Пошук тендера по ідентифікатору    ${username}    ${arguments[0]}
    ${rrr}=    Get Location
    Log To Console    ${rrr}
    ${rrr}=    Get Element Attribute    id=purchaseUrlOwner@href    #//a[contains(@href,'auction-sandbox')]@href
    Log To Console    ${rrr}
    Return From Keyword    ${rrr}
    [Return]    ${rrr}

aps.Отримати посилання на аукціон для глядача
    [Arguments]    ${username}    @{arguments}
    aps.Пошук тендера по ідентифікатору    ${username}    ${arguments[0]}
    Run Keyword And Ignore Error    Return From Keyword    Get Element Attribute    xpath=//a[@id='auctionUrl']@href
    Run Keyword And Ignore Error    Return From Keyword    Get Element Attribute    id=purchaseUrl@href

aps.Додати неціновий показник на лот
    [Arguments]    ${username}    @{arguments}
    aps.Пошук тендера по ідентифікатору    ${username}    ${arguments[0]}
    Full Click    id=purchaseEdit
    Full Click    id=features-tab
    ${fi}=    Set Variable    ${arguments[1]}
    ${fi.item_id}=    Set Variable    ${arguments[2]}
    Add Feature    ${fi}    1    0
    Full Click    id=movePurchaseView
    Publish tender

aps.Отримати документ до лоту
    [Arguments]    ${username}    @{arguments}
    aps.Пошук тендера по ідентифікатору    ${username}    ${arguments[0]}
    Full Click    id=documents-tab
    ${title}=    Get Field Text    xpath=.//*[@class="btn btn-primary ng-binding ng-scope" ][contains(@id,'strikeDocFileNameBut')]
    Return From Keyword    ${title}

aps.Відповісти на вимогу про виправлення умов закупівлі
    [Arguments]    ${username}    @{arguments}
    aps.Пошук тендера по ідентифікатору    ${username}    ${arguments[0]}
    Full Click    claim-tab
    Wait Until Page Contains Element    //span[contains(.,'${arguments[1]}')]    60
