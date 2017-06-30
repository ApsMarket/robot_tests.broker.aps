*** Settings ***
Library           String
Library           Collections
Library           Selenium2Library
Resource          ../../op_robot_tests/tests_files/keywords.robot
Resource          ../../op_robot_tests/tests_files/resource.robot
Resource          Locators.robot
Library           DateTime
Library           conv_timeDate.py
Resource          aps.robot

*** Variables ***
${enid}           ${0}
${locator_necTitle}    id=featureTitle_
${dkkp_id}        ${EMPTY}

*** Keywords ***
Открыть форму создания тендера
    Comment    Go To    http://192.168.90.170/purchase/create/0
    Wait Until Element Is Visible    ${locator_create_dop_zak}    8
    Click Element    ${locator_create_dop_zak}

Работа с жалобами

Переговорная мультилотовая процедура
    [Arguments]    ${tender_data}
    Run Keyword If    ${log_enabled}    Log To Console    Start negotiation
    Wait Until Element Is Visible    ${locator_button_create}    15
    Click Button    ${locator_button_create}
    Wait Until Element Is Enabled    ${locator_create_negotiation}    15
    Click Link    ${locator_create_negotiation}
    Wait Until Page Contains Element    ${locator_tenderTitle}
    Info Negotiate    ${tender_data}
    ${trtte}=    Get From Dictionary    ${tender_data}    data
    ${ttt}=    Get From Dictionary    ${trtte}    items
    ${item}=    Get From List    ${ttt}    0
    Add item negotiate    ${item}    00    0
    Comment    Wait Until Element Is Visible    xpath=.//*[@id='add_procurement_subject0']
    Comment    ${item}=    Get From List    ${ttt}    1
    Comment    Add item negotiate    ${item}    01    0
    Execute Javascript    window.scroll(-1000, -1000)
    Wait Until Page Contains Element    ${locator_finish_edit}
    Wait Until Element Is Enabled    ${locator_finish_edit}    30
    Click Button    ${locator_finish_edit}
    ${tender_UID}=    Publish tender/negotiation
    Run Keyword If    ${log_enabled}    Log To Console    End negotiation
    [Return]    ${tender_UID}

Открытые торги с публикацией на укр
    [Arguments]    ${tender}
    Wait Until Element Is Enabled    ${locator_button_create}    15
    Click Button    ${locator_button_create}
    Wait Until Element Is Enabled    ${locator_biddingUkr_create}    15
    Click Link    ${locator_biddingUkr_create}
    Info OpenUA    ${tender}
    Add Lot    1    ${tender.data.lots[0]}
    Wait Until Element Is Enabled    id=next_step    50
    aniwait
    Click Button    id=next_step
    ${items}=    Get From Dictionary    ${tender.data}    items
    ${item}=    Get From List    ${items}    0
    Add Item    ${item}    10    1
    Wait Until Element Is Enabled    id=next_step    30
    aniwait
    Click Button    id=next_step
    Add Feature    ${tender.data.features[1]}    0    0
    Add Feature    ${tender.data.features[0]}    1    0
    Add Feature    ${tender.data.features[2]}    1    0
    Run Keyword And Return    Publish tender

Открытые торги с публикацией на англ
    [Arguments]    ${tender}
    Wait Until Element Is Enabled    ${locator_button_create}    15
    Click Button    ${locator_button_create}
    Wait Until Element Is Enabled    ${locator_biddingEng_create}    15
    Click Link    ${locator_biddingEng_create}
    Info OpenEng    ${tender}
    ${ttt}=    Get From Dictionary    ${tender.data}    items
    ${item}=    Set Variable    ${ttt[0]}
    Add Item    ${item}    10    1
    Wait Until Element Is Not Visible    xpath=.//div[@class='page-loader animated fadeIn']    20
    Wait Until Element Is Enabled    id=next_step    30
    Click Button    id=next_step
    Add Feature    ${tender.data.features[1]}    0    0
    Add Feature    ${tender.data.features[0]}    1    0
    Add Feature    ${tender.data.features[2]}    1    0
    Execute Javascript    window.scroll(-1000, -1000)
    Run Keyword And Return    Publish tender

Допороговый однопредметный тендер
    [Arguments]    ${tender_data}
    Wait Until Element Is Visible    ${locator_button_create}    15
    Click Button    ${locator_button_create}
    Wait Until Element Is Enabled    ${locator_create_dop_zak}    15
    Click Link    ${locator_create_dop_zak}
    Wait Until Page Contains Element    ${locator_tenderTitle}
    Info Below    ${tender_data}
    ${ttt}=    Get From Dictionary    ${tender_data.data}    items
    ${item}=    Get From List    ${ttt}    0
    Add Item    ${item}    00    0
    ${tender_UID}=    Publish tender
    [Return]    ${tender_UID}

date_Time
    [Arguments]    ${date}
    ${DT}=    Convert Date    ${date}    date_format=
    Return From Keyword    '${DT.day}'+'.'+'${DT.month}'+'.'+'${DT.year}'+' '+'${DT.hour}'+':'+'${DT.minute}'
    [Return]    ${aps_date}

Add Item
    [Arguments]    ${item}    ${d}    ${d_lot}
    aniwait
    sleep    2
    #Клик доб позицию
    Wait Until Element Is Enabled    ${locator_add_item_button}${d_lot}    50
    Click Button    ${locator_add_item_button}${d_lot}
    Wait Until Element Is Enabled    ${locator_item_description}${d}    50
    #Название предмета закупки
    Input Text    ${locator_item_description}${d}    ${item.description}
    Execute Javascript    angular.element(document.getElementById('divProcurementSubjectControllerEdit')).scope().procurementSubject.guid='${item.id}'
    #Количество товара
    ${editItemQuant}=    Get From Dictionary    ${item}    quantity
    Wait Until Element Is Enabled    ${locator_Quantity}${d}
    Press Key    ${locator_Quantity}${d}    '${editItemQuant}'
    #Выбор ед измерения
    Wait Until Element Is Enabled    ${locator_code}${d}
    Select From List By Value    ${locator_code}${d}    ${item.unit.code}
    ${name}=    Get From Dictionary    ${item.unit}    name
    #Выбор ДК
    Click Button    ${locator_button_add_cpv}
    Wait Until Element Is Enabled    ${locator_cpv_search}
    ${cpv}=    Get From Dictionary    ${item.classification}    id
    Press Key    ${locator_cpv_search}    ${cpv}
    Wait Until Element Is Enabled    //*[@id='tree']//li[@aria-selected="true"]    30
    Wait Until Element Is Enabled    ${locator_add_classfier}
    Click Button    ${locator_add_classfier}
    ${is_dkpp}=    Run Keyword And Ignore Error    Dictionary Should Contain Key    ${item}    additionalClassifications
    Log To Console    cpv ${cpv}
    Set Suite Variable    ${dkkp_id}    000
    Run Keyword If    '${is_dkpp[0]}'=='PASS'    Get OtherDK    ${item}
    Set DKKP
    Run Keyword And Ignore Error    Wait Until Element Is Not Visible    xpath=//div[@class="modal-backdrop fade"]
    #Срок поставки (начальная дата)
    ${date_time}=    dt    ${item.deliveryDate.startDate}
    Fill Date    ${locator_date_delivery_start}${d}    ${date_time}
    #Срок поставки (конечная дата)
    ${date_time}=    dt    ${item.deliveryDate.endDate}
    Fill Date    ${locator_date_delivery_end}${d}    ${date_time}
    Execute Javascript    window.scroll(0, 1000)
    Click Element    xpath=.//*[@id='is_delivary_${d}']/div[1]/div[2]/div
    #Выбор страны
    Select From List By Label    xpath=.//*[@id='select_countries${d}']['Україна']    ${item.deliveryAddress.countryName}
    Press Key    ${locator_postal_code}${d}    ${item.deliveryAddress.postalCode}
    Run Keyword And Ignore Error    Wait Until Element Is Not Visible    xpath=.//div[@class="page-loader animated fadeIn"]    5
    Wait Until Element Is Enabled    id=select_regions${d}
    Set Region    ${item.deliveryAddress.region}    ${d}
    Execute Javascript    window.scroll(1000, 1000)
    Press Key    ${locator_street}${d}    ${item.deliveryAddress.streetAddress}
    Press Key    ${locator_locality}${d}    ${item.deliveryAddress.locality}
    #Koordinate
    ${deliveryLocation_latitude}    Convert To String    ${item.deliveryLocation.latitude}
    ${deliveryLocation_latitude}    String.Replace String    ${deliveryLocation_latitude}    decimal    string
    Press Key    ${locator_deliveryLocation_latitude}${d}    ${deliveryLocation_latitude}
    ${deliveryLocation_longitude}=    Convert To String    ${item.deliveryLocation.longitude}
    ${deliveryLocation_longitude}=    String.Replace String    ${deliveryLocation_longitude}    decimal    string
    Press Key    ${locator_deliveryLocation_longitude}${d}    ${deliveryLocation_longitude}
    Run Keyword If    '${MODE}'=='openeu'    Add Item Eng    ${item}    ${d}
    #Клик кнопку "Створити"
    Execute Javascript    window.scroll(1000, 1000)
    Run Keyword And Ignore Error    Wait Until Element Is Not Visible    xpath=.//div[@class='page-loader animated fadeIn']    5
    Wait Until Element Is Enabled    ${locator_button_create_item}${d}
    Click Button    ${locator_button_create_item}${d}
    Log To Console    finish item ${d}

Info Below
    [Arguments]    ${tender_data}
    #Ввод названия тендера
    ${title}=    Get From Dictionary    ${tender_data.data}    title
    Input Text    ${locator_tenderTitle}    ${title}
    #Ввод описания
    ${descr}=    Get From Dictionary    ${tender_data.data}    description
    Input Text    ${locator_description}    ${descr}
    #Выбор НДС
    ${PDV}=    Get From Dictionary    ${tender_data.data.value}    valueAddedTaxIncluded
    Click Element    ${locator_pdv}
    Execute Javascript    window.scroll(1000, 1000)
    #Валюта
    Wait Until Element Is Enabled    ${locator_currency}    15
    Click Element    ${locator_currency}
    ${currency}=    Get From Dictionary    ${tender_data.data.value}    currency
    Select From List By Label    ${locator_currency}    ${currency}
    #Ввод бюджета
    ${budget}=    Get From Dictionary    ${tender_data.data.value}    amount
    ${text}=    Convert Float To String    ${budget}
    ${text}=    String.Replace String    ${text}    .    ,
    Press Key    ${locator_budget}    ${text}
    #Ввод мин шага
    ${min_step}=    Get From Dictionary    ${tender_data.data.minimalStep}    amount
    ${text_ms}=    Convert Float To String    ${min_step}
    ${text_ms}=    String.Replace String    ${text_ms}    .    ,
    Press Key    ${locator_min_step}    ${text_ms}
    sleep    10
    #Период уточнений нач дата
    ${enquiry_start}=    Get From Dictionary    ${tender_data.data.enquiryPeriod}    startDate
    ${date_time_enq_st}=    dt    ${enquiry_start}
    #Период уточнений кон дата
    ${enquiry end}=    Get From Dictionary    ${tender_data.data.enquiryPeriod}    endDate
    ${date_time_enq_end}=    dt    ${enquiry end}
    #Период приема предложений (нач дата)
    ${tender_start}=    Get From Dictionary    ${tender_data.data.tenderPeriod}    startDate
    ${date_time_ten_st}=    dt    ${tender_start}
    #Период приема предложений (кон дата)
    ${tender_end}=    Get From Dictionary    ${tender_data.data.tenderPeriod}    endDate
    ${date_time_ten_end}=    dt    ${tender_end}
    Fill Date    ${locator_discussionDate_start}    ${date_time_enq_st}
    Fill Date    ${locator_discussionDate_end}    ${date_time_enq_end}
    Fill Date    ${locator_bidDate_start}    ${date_time_ten_st}
    Fill Date    ${locator_bidDate_end}    ${date_time_ten_end}
    Click Element    id=createOrUpdatePurchase
    Click Button    ${locator_button_next_step}

Info Negotiate
    [Arguments]    ${tender_data}
    Run Keyword If    ${log_enabled}    Log To Console    start info negotiation
    #Ввод названия закупки
    ${title}=    Get From Dictionary    ${tender_data.data}    title
    Press Key    ${locator_tenderTitle}    ${title}
    Run Keyword If    ${log_enabled}    Log To Console    Ввод названия закупки ${title}
    #Примечания
    ${description}=    Get From Dictionary    ${tender_data.data}    description
    Press Key    ${locator_description}    ${description}
    Run Keyword If    ${log_enabled}    Log To Console    Примечания ${description}
    #Условие применения переговорной процедуры
    ${select_directory_causes}=    Get From Dictionary    ${tender_data.data}    cause
    Click Element    ${locator_directory_cause}
    ${p}=    Set Variable    xpath=.//*[@ng-bind="directoryCause.cause"][text()='${select_directory_causes}']/../span[2]
    Click Element    xpath=.//*[@ng-bind="directoryCause.cause"][text()='${select_directory_causes}']/../span[2]
    Click Element    xpath=html/body
    Run Keyword If    ${log_enabled}    Log To Console    Условие применения переговорной процедуры ${select_directory_causes}
    #Обоснование
    ${cause_description}=    Get From Dictionary    ${tender_data.data}    causeDescription
    Press Key    ${locator_cause_description}    ${cause_description}
    Run Keyword If    ${log_enabled}    Log To Console    Обоснование \ ${cause_description}
    #Выбор НДС
    ${PDV}=    Get From Dictionary    ${tender_data.data.value}    valueAddedTaxIncluded
    Click Element    ${locator_pdv}
    Run Keyword If    ${log_enabled}    Log To Console    Выбор НДС ${PDV}
    #Валюта
    Wait Until Element Is Enabled    ${locator_currency}    15
    ${currency}=    Get From Dictionary    ${tender_data.data.value}    currency
    Select From List By Label    ${locator_currency}    ${currency}
    Press Key    ${locator_currency}    ${currency}
    Run Keyword If    ${log_enabled}    Log To Console    Валюта ${currency}
    #Стоимость закупки
    ${budget}=    Get From Dictionary    ${tender_data.data.value}    amount
    ${text}=    Convert Float To String    ${budget}
    ${text}=    String.Replace String    ${text}    .    ,
    Press Key    ${locator_budget}    ${text}
    Run Keyword If    ${log_enabled}    Log To Console    Стоимость закупки ${text}
    Click Button    ${locator_next_step}
    Run Keyword If    ${log_enabled}    Log To Console    end info negotiation

Login
    [Arguments]    ${user}
    Wait Until Element Is Visible    ${locator_cabinetEnter}    30
    Click Element    ${locator_cabinetEnter}
    Click Element    ${locator_enter}
    Wait Until Element Is Visible    ${locator_emailField}    10
    Input Text    ${locator_emailField}    ${user.login}
    Input Text    ${locator_passwordField}    ${user.password}
    Click Element    ${locator_loginButton}

Load document
    [Arguments]    ${filepath}    ${to}    ${to_name}
    Wait Until Element Is Enabled    ${locator_documents}
    Click Element    ${locator_documents}
    Run Keyword And Ignore Error    Wait Until Element Is Not Visible    xpath=.//div[@class="page-loader animated fadeIn"]
    Wait Until Page Contains Element    ${locator_add_ documents}
    Wait Until Element Is Enabled    ${locator_add_ documents}
    Run Keyword And Ignore Error    Wait Until Element Is Not Visible    xpath=.//div[@class="page-loader animated fadeIn"]
    Click Element    ${locator_add_ documents}
    Wait Until Element Is Enabled    ${locator_documents}
    Click Element    ${locator_documents}
    Click Element    ${locator_category}
    Wait Until Page Contains Element    ${locator_category}
    Wait Until Element Is Enabled    ${locator_category}
    Select From List By Value    ${locator_category}    biddingDocuments
    Click Element    ${locator_add_documents_to}
    Select From List By Value    ${locator_add_documents_to}    ${to}
    Run Keyword If    '${to}'=='Lot'    Select Doc For Lot    ${to_name}
    Wait Until Page Contains Element    ${locator_download}
    Choose File    ${locator_download}    ${filepath}
    Click Button    ${locator_save_document}

Search tender
    [Arguments]    ${username}    ${tender_uaid}
    Run Keyword If    '${role}'!='tender_owner'    Sync    ${tender_uaid}
    Wait Until Page Contains Element    ${locator_search_type}
    Select From List By Value    ${locator_search_type}    1    #По Id
    Wait Until Page Contains Element    ${locator_input_search}
    Wait Until Element Is Enabled    ${locator_input_search}
    Input Text    ${locator_input_search}    ${tender_uaid}
    Wait Until Element Is Enabled    id=butSimpleSearch
    aniwait
    Click Element    id=butSimpleSearch
    Wait Until Page Contains Element    xpath=//span[@class="hidden"][text()="${tender_uaid}"]/../a    50
    Log To Console    bbbb111
    aniwait
    Log To Console    bbbb222
    ${msg}=    Run Keyword And Ignore Error    Click Element    xpath=//span[@class="hidden"][text()="${tender_uaid}"]/../a
    Run Keyword If    '${msg[0]}'=='FAIL'    Capture Page Screenshot    fail_click_link.png

Info OpenUA
    [Arguments]    ${tender}
    #Ввод названия закупки
    Wait Until Page Contains Element    ${locator_tenderTitle}
    ${descr}=    Get From Dictionary    ${tender.data}    title
    Input Text    ${locator_tenderTitle}    ${descr}
    Input Text    id=description    ${tender.data.description}
    #Выбор НДС
    ${PDV}=    Get From Dictionary    ${tender.data.value}    valueAddedTaxIncluded
    Click Element    ${locator_pdv}
    Execute Javascript    angular.element(document.getElementById('purchaseAccelerator')).scope().purchase.accelerator = 1444
    #Валюта
    Wait Until Element Is Enabled    ${locator_currency}    15
    Click Element    ${locator_currency}
    ${currency}=    Get From Dictionary    ${tender.data.value}    currency
    Select From List By Label    ${locator_currency}    ${currency}
    Run Keyword If    ${NUMBER_OF_LOTS}<1    Set Tender Budget    ${tender}
    Run Keyword If    ${NUMBER_OF_LOTS}>0    Click Element    ${locator_multilot_enabler}
    #Период приема предложений (кон дата)
    ${tender_end}=    Get From Dictionary    ${tender.data.tenderPeriod}    endDate
    ${date_time_ten_end}=    dt    ${tender_end}
    Fill Date    ${locator_bidDate_end}    ${date_time_ten_end}
    Click Element    id=createOrUpdatePurchase
    Wait Until Element Is Enabled    ${locator_button_next_step}    20
    Click Button    ${locator_button_next_step}
    Log To Console    finish openUa info

Add item negotiate
    [Arguments]    ${item}    ${q}    ${w}
    Run Keyword If    ${log_enabled}    Log To Console    start add item negotiation
    #Клик доб позицию
    Comment    Wait Until Element Is Enabled    ${locator_items}    35
    Comment    Click Element    ${locator_items}
    sleep    3
    Wait Until Element Is Enabled    ${locator_add_item_button}${w}    30
    Click Button    ${locator_add_item_button}${w}
    Wait Until Element Is Enabled    ${locator_item_description}${q}
    Run Keyword If    ${log_enabled}    Log To Console    Click add item
    #Название предмета закупки
    ${add_classif}=    Get From Dictionary    ${item}    description
    Press Key    ${locator_item_description}${q}    ${add_classif}
    Run Keyword If    ${log_enabled}    Log To Console    Название предмета закупки ${add_classif}
    #Количество товара
    ${editItemQuant}=    Get From Dictionary    ${item}    quantity
    Wait Until Element Is Enabled    ${locator_Quantity}${q}
    Input Text    ${locator_Quantity}${q}    ${editItemQuant}
    Run Keyword If    ${log_enabled}    Log To Console    Количество товара ${editItemQuant}
    #Выбор ед измерения
    Wait Until Element Is Enabled    ${locator_code}${q}
    ${code}=    Get From Dictionary    ${item.unit}    code
    Select From List By Value    ${locator_code}${q}    ${code}
    ${name}=    Get From Dictionary    ${item.unit}    name
    Run Keyword If    ${log_enabled}    Log To Console    Выбор ед измерения ${code} ${name}
    #Выбор ДК
    Click Button    ${locator_button_add_cpv}
    Wait Until Element Is Enabled    ${locator_cpv_search}
    ${cpv}=    Get From Dictionary    ${item.classification}    id
    Press Key    ${locator_cpv_search}    ${cpv}
    Wait Until Element Is Enabled    //*[@id='tree']//li[@aria-selected="true"]    30
    Wait Until Element Is Enabled    ${locator_add_classfier}
    Click Button    ${locator_add_classfier}
    Run Keyword If    ${log_enabled}    Log To Console    Выбор ДК ${cpv}
    #Выбор др ДК
    sleep    1
    ${is_dkpp}=    Run Keyword And Ignore Error    Dictionary Should Contain Key    ${item}    additionalClassifications
    Log To Console    is DKKP - \ ${is_dkpp[0]} \ - \ ${is_dkpp[1]}
    Log To Console    cpv ${cpv}
    Set Suite Variable    ${dkkp_id}    000
    Run Keyword If    '${is_dkpp[0]}'=='PASS'    Get OtherDK    ${item}
    Set DKKP
    Run Keyword If    ${log_enabled}    Log To Console    Выбор др ДК ${is_dkpp}
    #Срок поставки (начальная дата)
    sleep    10
    ${delivery_Date_start}=    Get From Dictionary    ${item.deliveryDate}    startDate
    ${date_time}=    dt    ${delivery_Date_start}
    Fill Date    ${locator_date_delivery_start}${q}    ${date_time}
    Run Keyword If    ${log_enabled}    Log To Console    Срок поставки (начальная дата) ${date_time}
    #Срок поставки (конечная дата)
    ${delivery_Date}=    Get From Dictionary    ${item.deliveryDate}    endDate
    ${date_time}=    dt    ${delivery_Date}
    Fill Date    ${locator_date_delivery_end}${q}    ${date_time}
    Run Keyword If    ${log_enabled}    Log To Console    Срок поставки (конечная дата) ${date_time}
    Execute Javascript    window.scroll(1000, 1000)
    #Выбор страны
    ${country}=    Get From Dictionary    ${item.deliveryAddress}    countryName
    Select From List By Label    ${locator_country_id}${q}    ${country}
    Run Keyword If    ${log_enabled}    Log To Console    Выбор страны ${country}
    Execute Javascript    window.scroll(1000, 1000)
    #Выбор региона
    sleep    5
    ${region}=    Get From Dictionary    ${item.deliveryAddress}    region
    Set Region    ${region}    ${q}
    Comment    Execute Javascript    var autotestmodel=angular.element(document.getElementById('select_regions00')).scope(); autotestmodel.procurementSubject.procurementSubject.region=autotestmodel.procurementSubject.procurementSubject.region; autotestmodel.procurementSubject.procurementSubject.region={id:0,name:'${region}',initName:'${region}'};
    Comment    Comment    Select From List By Label    ${locator_SelectRegion}${q}    ${region}
    Run Keyword If    ${log_enabled}    Log To Console    Выбор региона ${region}
    #Индекс
    ${post_code}=    Get From Dictionary    ${item.deliveryAddress}    postalCode
    Press Key    ${locator_postal_code}${q}    ${post_code}
    Run Keyword If    ${log_enabled}    Log To Console    Индекс ${post_code}
    ${locality}=    Get From Dictionary    ${item.deliveryAddress}    locality
    Press Key    ${locator_locality}${q}    ${locality}
    Run Keyword If    ${log_enabled}    Log To Console    Насел пункт ${locality}
    ${street}=    Get From Dictionary    ${item.deliveryAddress}    streetAddress
    Press Key    ${locator_street}${q}    ${street}
    Run Keyword If    ${log_enabled}    Log To Console    Адрес ${street}
    sleep    3
    Click Element    ${locator_check_gps}${q}
    ${deliveryLocation_latitude}=    Get From Dictionary    ${item.deliveryLocation}    latitude
    ${deliveryLocation_latitude}    Convert To String    ${deliveryLocation_latitude}
    ${deliveryLocation_latitude}    String.Replace String    ${deliveryLocation_latitude}    decimal    string
    Press Key    ${locator_deliveryLocation_latitude}${q}    ${deliveryLocation_latitude}
    Run Keyword If    ${log_enabled}    Log To Console    Широта ${deliveryLocation_latitude}
    ${deliveryLocation_longitude}=    Get From Dictionary    ${item.deliveryLocation}    longitude
    ${deliveryLocation_longitude}=    Convert To String    ${deliveryLocation_longitude}
    ${deliveryLocation_longitude}=    String.Replace String    ${deliveryLocation_longitude}    decimal    string
    Press Key    ${locator_deliveryLocation_longitude}${q}    ${deliveryLocation_longitude}
    Run Keyword If    ${log_enabled}    Log To Console    Долгота ${deliveryLocation_longitude}
    Execute Javascript    window.scroll(1000, 1000)
    sleep    2
    #Клик кнопку "Створити"
    Click Button    ${locator_button_create_item}${q}
    sleep    2
    Run Keyword If    ${log_enabled}    Log To Console    end add item negotiation

Publish tender
    aniwait
    sleep    2
    Click Element    id=basicInfo-tab
    Run Keyword And Ignore Error    Wait Until Element Is Visible    id=save_changes
    Run Keyword And Ignore Error    Click Button    id=save_changes
    Wait Until Element Is Enabled    id=movePurchaseView
    aniwait
    Click Button    id=movePurchaseView
    Wait Until Page Contains Element    ${locator_publish_tender}    50
    Wait Until Element Is Enabled    ${locator_publish_tender}
    ${id}=    Get Location
    Log To Console    ${id}
    sleep    2
    Click Button    ${locator_publish_tender}
    Wait Until Page Contains Element    id=purchaseProzorroId    50
    Wait Until Element Is Visible    id=purchaseProzorroId    90
    aniwait
    ${tender_UID}=    Get Text    xpath=//span[@id='purchaseProzorroId']
    sleep    2
    Log To Console    publish tender ${tender_UID}
    Return From Keyword    ${tender_UID}
    [Return]    ${tender_UID}

Add question
    [Arguments]    ${tender_data}
    Select From List By Label    ${locator_question_to}    0
    ${title}=    Get From Dictionary    ${tender_data.data}    title
    Press Key    ${locator_question_title}    ${title}
    ${description}=    Get From Dictionary    ${tender_data.data}    description
    Press Key    ${locator_description_question}    ${description}

Add Lot
    [Arguments]    ${d}    ${lot}
    Wait Until Page Contains Element    ${locator_multilot_new}    60
    Wait Until Element Is Enabled    ${locator_multilot_new}    30
    Click Button    ${locator_multilot_new}
    Wait Until Page Contains Element    ${locator_multilot_title}${d}    30
    Wait Until Element Is Enabled    ${locator_multilot_title}${d}
    Input Text    ${locator_multilot_title}${d}    ${lot.title}
    Input Text    id=lotDescription_${d}    ${lot.description}
    Execute Javascript    angular.element(document.getElementById('divLotControllerEdit')).scope().lotPurchasePlan.guid='${lot.id}'
    ${budget}=    Get From Dictionary    ${lot.value}    amount
    ${text}=    Convert Float To String    ${budget}
    ${text}=    String.Replace String    ${text}    .    ,
    Input Text    id=lotBudget_${d}    ${text}
    ${step}=    Get From Dictionary    ${lot.minimalStep}    amount
    ${text}=    Convert Float To String    ${step}
    ${text}=    String.Replace String    ${text}    .    ,
    Press Key    id=lotMinStep_${d}    ${text}
    Press Key    id=lotMinStep_${d}    00
    #Input Text    id=lotGuarantee_${d}
    Wait Until Element Is Enabled    xpath=.//*[@id='updateOrCreateLot_1']//button[@class="btn btn-success"]    30
    Click Button    xpath=.//*[@id='updateOrCreateLot_1']//button[@class="btn btn-success"]
    Comment    Run Keyword And Ignore Error    Wait Until Page Contains Element    ${locator_toast_container}
    Comment    Run Keyword And Ignore Error    Click Button    ${locator_toast_close}
    Log To Console    finish lot ${d}

Fill Date
    [Arguments]    ${id}    ${value}
    ${id}    Replace String    ${id}    id=    ${EMPTY}
    ${ddd}=    Set Variable    SetDateTimePickerValue(\'${id}\',\'${value}\');
    Execute Javascript    ${ddd}

Set Tender Budget
    [Arguments]    ${tender}
    #Ввод бюджета
    ${budget}=    Get From Dictionary    ${tender.data.value}    amount
    ${text}=    Convert Float To String    ${budget}
    ${text}=    String.Replace String    ${text}    .    ,
    Press Key    ${locator_budget}    ${text}
    #Ввод мин шага
    ${min_step}=    Get From Dictionary    ${tender.data.minimalStep}    amount
    ${text_ms}=    Convert Float To String    ${min_step}
    ${text_ms}=    String.Replace String    ${text_ms}    .    ,
    Press Key    ${locator_min_step}    ${text_ms}

Info OpenEng
    [Arguments]    ${tender}
    Log To Console    start openEng info
    #Ввод названия закупки
    Wait Until Page Contains Element    ${locator_tenderTitle}
    ${descr}=    Get From Dictionary    ${tender.data}    title
    Input Text    ${locator_tenderTitle}    ${descr}
    Wait Until Page Contains Element    ${locator_titleEng}
    ${descrEng}=    Get From Dictionary    ${tender.data}    title_en
    Input Text    ${locator_titleEng}    ${descrEng}
    #Выбор НДС
    ${PDV}=    Get From Dictionary    ${tender.data.value}    valueAddedTaxIncluded
    Click Element    ${locator_pdv}
    #Выбор многолотовости
    Wait Until Element Is Enabled    ${locator_multilot_enabler}
    Click Element    ${locator_multilot_enabler}
    #Валюта
    Wait Until Element Is Enabled    ${locator_currency}    15
    Click Element    ${locator_currency}
    ${currency}=    Get From Dictionary    ${tender.data.value}    currency
    Select From List By Label    ${locator_currency}    ${tender.data.value.currency}
    Press Key    ${locator_currency}    ${currency}
    #Период приема предложений (кон дата)
    ${tender_end}=    Get From Dictionary    ${tender.data.tenderPeriod}    endDate
    ${date_time_ten_end}=    dt    ${tender_end}
    Fill Date    ${locator_bidDate_end}    ${date_time_ten_end}
    Wait Until Element Is Enabled    ${locator_button_next_step}    20
    Click Button    ${locator_button_next_step}
    Log To Console    finish openEng info
    #Добавление лота
    Wait Until Page Contains Element    ${locator_multilot_new}
    Wait Until Element Is Enabled    ${locator_multilot_new}    30
    Click Button    ${locator_multilot_new}
    ${w}=    Set Variable    1
    ${lot}=    Get From Dictionary    ${tender.data}    lots
    ${lot}=    Get From List    ${lot}    0
    Log To Console    ${locator_multilot_title}${w}
    Wait Until Page Contains Element    ${locator_multilot_title}${w}
    Wait Until Element Is Enabled    ${locator_multilot_title}${w}
    Input Text    ${locator_multilot_title}${w}    ${lot.title}
    ${lot.title_en}=    Get From Dictionary    ${tender.data}    title_en
    Press Key    ${locator_lotTitleEng}${w}    ${lot.title_en}
    Input Text    id=lotDescription_${w}    ${lot.description}
    Input Text    id=lotBudget_${w}    '${lot.value.amount}'
    Press Key    id=lotMinStep_${w}    '${lot.minimalStep.amount}'
    Press Key    id=lotMinStep_${w}    ////13
    #Input Text    id=lotGuarantee_${w}
    Click Button    xpath=.//*[@id='updateOrCreateLot_1']//button[@class="btn btn-success"]
    Run Keyword And Ignore Error    Wait Until Page Contains Element    ${locator_toast_container}
    Run Keyword And Ignore Error    Click Button    ${locator_toast_close}
    Wait Until Page Contains Element    xpath=.//*[@id='updateOrCreateLot_1']//a[@ng-click="editLot(lotPurchasePlan)"]
    Log To Console    finish lot ${w}
    #нажатие след.шаг
    Click Button    ${locator_next_step}

Add Item Eng
    [Arguments]    ${item}    ${d}
    #Название предмета закупки
    Wait Until Element Is Enabled    ${locator_item_descriptionEng}${d}
    ${add_classifEng}=    Get From Dictionary    ${item}    description_en
    Log To Console    ${add_classifEng} \ \ \ \ \ \ ${locator_item_descriptionEng}${d}
    Input Text    ${locator_item_descriptionEng}${d}    ${add_classifEng}

Add Feature
    [Arguments]    ${fi}    ${lid}    ${pid}
    Wait Until Element Is Enabled    id=add_features${lid}    50
    aniwait
    Log To Console    3333
    Wait Until Element Is Visible    id=add_features${lid}    50
    Click Button    id=add_features${lid}
    Log To Console    4444
    Wait Until Element Is Enabled    id=featureTitle_${lid}_${pid}
    #Param0
    Input Text    id=featureTitle_${lid}_${pid}    ${fi.title}
    Run Keyword If    '${MODE}'=='openeu'    Input Text    id=featureTitle_En_${lid}_${pid}    ${fi.title_en}
    Input Text    id=featureDescription_${lid}_${pid}    ${fi.description}
    # Position nec
    ${status}=    Run Keyword And Ignore Error    Dictionary Should Contain Key    ${fi}    item_id
    Run Keyword If    '${fi.featureOf}'=='item'    Run Keyword If    '${status[0]}'=='FAIL'    Select Item Param    ${fi.relatedItem}
    Run Keyword If    '${fi.featureOf}'=='item'    Run Keyword If    '${status[0]}'=='PASS'    Select Item Param Label    ${fi.item_id}
    #Enum_0_1
    Set Suite Variable    ${enid}    ${0}
    ${enums}=    Get From Dictionary    ${fi}    enum
    : FOR    ${enum}    IN    @{enums}
    \    ${val}=    Evaluate    int(${enum.value}*${100})
    \    #Log To Console    val = \ ${val}
    \    Run Keyword If    ${val}>0    Add Enum    ${enum}    ${lid}_${pid}
    \    Run Keyword If    ${val}==0    Input Text    id=featureEnumTitle_${lid}_${pid}_0    ${enum.title}
    \    Run Keyword If    (${val}==0)&('${MODE}'=='openeu')    Input Text    id=featureEnumTitleEn_${lid}_${pid}_0    flowers
    \    #Input Text    id=featureEnumDescription_${lid}_0_1    ${enum.}
    Wait Until Element Is Enabled    id=updateFeature_${lid}_${pid}
    Click Button    id=updateFeature_${lid}_${pid}

Set DKKP
    Log To Console    ${dkkp_id}
    #Выбор др ДК
    sleep    1
    Wait Until Element Is Enabled    ${locator_button_add_dkpp}
    Click Button    ${locator_button_add_dkpp}
    Wait Until Element Is Visible    ${locator_dkpp_search}
    Clear Element Text    ${locator_dkpp_search}
    Press Key    ${locator_dkpp_search}    ${dkkp_id}
    Wait Until Element Is Enabled    //*[@id='tree']//li[@aria-selected="true"]    30
    Wait Until Element Is Enabled    ${locator_add_classfier}
    Click Button    ${locator_add_classfier}

Add Enum
    [Arguments]    ${enum}    ${p}
    ${val}=    Evaluate    int(${enum.value}*${100})
    Click Button    xpath=//button[@ng-click="addFeatureEnum(lotPurchasePlan, features)"]
    ${enid_}=    Evaluate    ${enid}+${1}
    Set Suite Variable    ${enid}    ${enid_}
    ${end}=    Set Variable    ${p}_${enid}
    #Log To Console    id=featureEnumValue_${end}
    Wait Until Page Contains Element    id=featureEnumValue_${end}    15
    Comment    Run Keyword And Return If    '${MODE}'=='openeu'    Input Text    id=featureEnumTitle_En${end}    ${enum.title_en}
    Input Text    id=featureEnumValue_${end}    ${val}
    Input Text    id=featureEnumTitle_${end}    ${enum.title}
    Run Keyword And Return If    '${MODE}'=='openeu'    Input Text    id=featureEnumTitleEn_${end}    flowers

Sync
    [Arguments]    ${uaid}
    ${off}=    Get Current Date    local    -5m    %Y-%m-%d %H:%M    true
    Log To Console    Synk \ date=${off}&tenderId=${uaid}
    Execute Javascript    $.get('../publish/SearchTenderById?date=${off}&tenderId=${uaid}&guid=ac8dd2f8-1039-4e27-8d98-3ef50a728ebf')
    sleep    2

Get OtherDK
    [Arguments]    ${item}
    ${dkpp}=    Get From List    ${item.additionalClassifications}    0
    ${dkpp_id_local}=    Get From Dictionary    ${dkpp}    id
    Log To Console    Other DK ${dkpp_id_local}
    Set Suite Variable    ${dkkp_id}    ${dkpp_id_local}

Add participant into negotiate
    [Arguments]    ${tender_data}

Publish tender/negotiation
    Run Keyword If    ${log_enabled}    Log To Console    start publish tender
    Log To Console    start publish tender
    Comment    Wait Until Page Contains Element    ${locator_toast_container}
    Comment    Click Button    ${locator_toast_close}
    Run Keyword And Ignore Error    Wait Until Element Is Not Visible    xpath=.//div[@class='page-loader animated fadeIn']    30
    sleep    10
    Comment    Wait Until Page Contains Element    ${locator_finish_edit}
    Comment    Wait Until Element Is Enabled    ${locator_finish_edit}    30
    Comment    Click Button    ${locator_finish_edit}
    Wait Until Page Contains Element    id=publishNegotiationAutoTest    90
    Wait Until Element Is Enabled    id=publishNegotiationAutoTest
    sleep    3
    Execute Javascript    $("#publishNegotiationAutoTest").click()
    ${url}=    Get Location
    Log To Console    ${url}
    sleep    5
    Comment    Wait Until Page Contains Element    id=purchaseProzorroId    50
    Comment    ${tender_UID}=    Execute Javascript    var model=angular.element(document.getElementById('purchse-controller')).scope(); return model.$$childHead.purchase.purchase.prozorroId
    Wait Until Element Is Visible    id=purchaseProzorroId    90
    ${tender_UID}=    Get Text    id=purchaseProzorroId
    Log To Console    finish publish tender ${tender_UID}
    Reload Page
    Return From Keyword    ${tender_UID}
    Run Keyword If    ${log_enabled}    Log To Console    end publish tender
    [Return]    ${tender_UID}

Select Item Param
    [Arguments]    ${relatedItem}
    Wait Until Page Contains Element    xpath=//label[@for='featureOf_1_0']
    Wait Until Element Is Visible    xpath=//label[@for='featureOf_1_0']
    Click Element    xpath=//label[@for='featureOf_1_0']
    Wait Until Page Contains Element    id=featureItem_1_0
    Wait Until Element Is Enabled    id=featureItem_1_0
    Select From List By Value    id=featureItem_1_0    string:${relatedItem}

Select Doc For Lot
    [Arguments]    ${arg}
    Click Element    xpath=//select[@name='DocumentOf']
    Wait Until Page Contains Element    id=documentOfLotSelect    30
    Wait Until Element Is Enabled    id=documentOfLotSelect
    ${arg}=    Get Text    xpath=//option[contains(@label,'${arg}')]
    Log To Console    value - ${arg}
    Select From List By Label    id=documentOfLotSelect    ${arg}

Set Field tenderPeriod.endDate
    [Arguments]    ${value}
    ${date_time_ten_end}=    Replace String    ${value}    T    ${SPACE}
    Log To Console    ${date_time_ten_end}
    Fill Date    ${locator_bidDate_end}    ${date_time_ten_end}
    Click Element    ${locator_bidDate_end}
    Click Element    id=createOrUpdatePurchase

Set Region
    [Arguments]    ${region}    ${item_no}
    Execute Javascript    var autotestmodel=angular.element(document.getElementById('select_regions${item_no}')).scope(); autotestmodel.regions.push({id:0,name:'${region}'}); autotestmodel.$apply(); autotestmodel; \ $("#select_regions${item_no} option[value='0']").attr("selected", "selected"); var autotestmodel=angular.element(document.getElementById('procurementSubject_description${item_no}')).scope(); \ autotestmodel.procurementSubject.region.id=0; autotestmodel.procurementSubject.region.name='${region}';

Select Item Param Label
    [Arguments]    ${relatedItem}
    Log To Console    ad item param \ ${relatedItem}
    Wait Until Page Contains Element    xpath=//label[@for='featureOf_1_0']
    Wait Until Element Is Visible    xpath=//label[@for='featureOf_1_0']
    Click Element    xpath=//label[@for='featureOf_1_0']
    Wait Until Page Contains Element    id=featureItem_1_0
    Wait Until Element Is Enabled    id=featureItem_1_0
    ${lb}=    Get Element Attribute    xpath=//select[@id='featureItem_1_0']/option[contains(@label,'${relatedItem}')]@label
    Log To Console    ${lb}
    Select From List By Label    id=featureItem_1_0    ${lb}

aniwait
    Wait For Condition    return $(".page-loader").css("display")=="none"    120
