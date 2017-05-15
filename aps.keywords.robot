*** Settings ***
Library           String
Library           Collections
Library           Selenium2Library
Resource          ../../op_robot_tests/tests_files/keywords.robot
Resource          ../../op_robot_tests/tests_files/resource.robot
Resource          Locators.robot
Library           DateTime
Library           conv_timeDate.py
Resource          Angular.robot

*** Keywords ***
Открыть форму создания тендера
    Comment    Go To    http://192.168.90.170/purchase/create/0
    Wait Until Element Is Visible    ${locator_create_dop_zak}    8
    Click Element    ${locator_create_dop_zak}

Работа с жалобами

Переговорная мультилотовая процедура
    [Arguments]    ${arg1}

Открытые торги с публикацией на укр
    [Arguments]    ${arg1}

Открытые торги с публикацией на англ

Допороговый однопредметный тендер
    [Arguments]    ${tender_data}
    Wait Until Element Is Visible    ${locator_button_create}    15
    Click Button    ${locator_button_create}
    Wait Until Element Is Enabled    ${locator_create_dop_zak}    15
    sleep    3
    Click Link    ${locator_create_dop_zak}
    Wait Until Page Contains Element    ${locator_tenderTitle}
    Log To Console    до информ о закупке
    Информация по закупке    ${tender_data.data.enquiryPeriod}    ${tender_data.data.tenderPeriod}    ${tender_data}
    Comment    Click Button    ${locator_button_next_step}
    ${trtte}=    Get From Dictionary    ${tender_data}    data
    ${ttt}=    Get From Dictionary    ${trtte}    items
    ${item}=    Get From List    ${ttt}    0
    Comment    Execute Javascript    window.scroll(800, 800)
    Comment    Wait Until Element Is Visible    ${locator_tenderTitle}
    sleep    3
    Добавить позицию    ${item}
    Click Element    ${next_step}
    ${UAID}=    Опубликовать закупку

Поиск тендера по идентификатору
    [Arguments]    ${username}    ${tender_uaid}
    Open Browser    http://192.168.90.170    chrome
    Input Text    ${locator_search}    ${tender_uaid}
    Wait Until Element Is Enabled    ${locator_search-btn}
    Click Element    ${locator_search-btn}
    Click Element    xpath=.//*[@id='purchases']/div[1]/div/div/div/div[2]/a[text()="${tender_uaid}"]    #поменять путь

Опубликовать закупку
    Click Element    ${loc_TenderPublishTop}
    Wait Until Element Is Enabled    ${loc_PublishConfirm}
    Click Element    xpath=.//*[@id='optionsRadiosNotEcp']/..
    Click Button    xpath=.//*[@class='btn btn-success ecp_true hidden']

date_Time
    [Arguments]    ${date}
    ${DT}=    Convert Date    ${date}    date_format=
    Return From Keyword    '${DT.day}'+'.'+'${DT.month}'+'.'+'${DT.year}'+' '+'${DT.hour}'+':'+'${DT.minute}'
    [Return]    ${aps_date}

Добавить позицию
    [Arguments]    ${item}
    #Клик доб позицию
    Click Element    ${locator_items}
    sleep    3
    Wait Until Element Is Enabled    ${locator_add_item_button}
    Click Button    ${locator_add_item_button}
    Comment    Wait Until Page Contains    ${locator_item_description}
    Wait Until Element Is Enabled    ${locator_item_description}
    sleep    3
    #Название предмета закупки
    ${add_classif}=    Get From Dictionary    ${item}    additionalClassifications
    ${itemDescript}=    Get From List    ${add_classif}    0
    ${itemDescript}=    Get From Dictionary    ${itemDescript}    description
    Input Text    ${locator_item_description}    ${itemDescript}
    Define angular +id_mod    procurementSubject    procurementSubject_description00    ${itemDescript}    description
    #Количество товара
    ${editItemQuant}=    Get From Dictionary    ${item}    quantity
    Input Text    ${locator_Quantity}    ${editItemQuant}
    Define angular +id_mod    procurementSubject    procurementSubject_quantity00    ${editItemQuant}    quantity
    #Выбор ед измерения
    Wait Until Element Is Enabled    ${locator_code}
    ${code}=    Get From Dictionary    ${item.unit}    code
    Select From List By Value    ${locator_code}    ${code}
    Comment    Define angular    procurementSubject    procurementSubject    ${code}
    #Выбор ДК
    Click Button    ${locator_button_add_cpv}
    Wait Until Element Is Visible    ${locator_cpv_search}
    ${cpv}=    Get From Dictionary    ${item.classification}    id
    Input Text    ${locator_cpv_search}    ${cpv}
    sleep    5
    Wait Until Element Is Enabled    xpath=.//*[@id='tree']
    Click Button    ${locator_add_classfier}
    #Выбор др ДК
    sleep    3
    Wait Until Element Is Visible    ${locator_button_add_dkpp}
    Click Button    ${locator_button_add_dkpp}
    Wait Until Element Is Visible    ${locator_dkpp_search}
    Clear Element Text    ${locator_dkpp_search}
    ${dkpp_q}=    Get From Dictionary    ${item}    additionalClassifications
    ${dkpp_w}=    Get From List    ${dkpp_q}    0
    ${dkpp}=    Get From Dictionary    ${dkpp_w}    id
    Log To Console    ${dkpp}
    Input Text    ${locator_dkpp_search}    ${dkpp}
    sleep    7
    Click Button    ${locator_add_classfier}
    #Срок поставки (конечная дата)
    ${delivery_Date}=    Get From Dictionary    ${item.deliveryDate}    endDate
    ${date_time}=    dt    ${delivery_Date}
    Input Text    ${locator_date_delivery_end}    ${date_time}
    Define angular date end -.End    procurementSubject    delivery_end_    ${date_time}    deliveryEnd
    #Клик Enter
    Press Key    ${locator_date_delivery_end}    \\\13
    sleep    5
    Click Element    ${locator_check_location}
    Execute Javascript    window.scroll(1000, 1000)
    sleep    15
    #Выбор страны
    Comment    ${country}=    Get From Dictionary    ${item.deliveryAddress}    countryName
    Comment    Select From List By Label    ${locator_country_id}    ${country}
    Comment    Input Text    ${locator_country_id}    ${country}
    Comment    Log To Console    ${country}
    Execute Javascript    window.scroll(1000, 1000)
    Comment    ${region}=    Get From Dictionary    ${item.deliveryAddress}    region
    Comment    Input Text    ${locator_SelectRegion}    ${region}
    ${post_code}=    Get From Dictionary    ${item.deliveryAddress}    postalCode
    Input Text    ${locator_postal_code}    ${post_code}
    Define angular +name+id_mod    procurementSubject    zip_code_00    ${post_code}    zipCode    address
    ${locality}=    Get From Dictionary    ${item.deliveryAddress}    locality
    Input Text    ${locator_locality}    ${locality}
    Define angular +name+id_mod    procurementSubject    locality_00    ${locality}    locality    address
    ${street}=    Get From Dictionary    ${item.deliveryAddress}    streetAddress
    Input Text    ${locator_street}    ${street}
    Define angular +name+id_mod    procurementSubject    street_00    ${street}    street    address
    Comment    sleep    500000
    ${deliveryLocation_latitude}=    Get From Dictionary    ${item.deliveryLocation}    latitude
    Input Text    ${locator_deliveryLocation_latitude}    ${deliveryLocation_latitude}
    Define angular latutide, longitude    procurementSubject    address    latutide    ${deliveryLocation_latitude}    latutide_00
    ${deliveryLocation_longitude}=    Get From Dictionary    ${item.deliveryLocation}    longitude
    Input Text    ${locator_deliveryLocation_longitude}    ${deliveryLocation_longitude}
    Define angular latutide, longitude    procurementSubject    address    longitude    ${deliveryLocation_longitude}    longitude_00
    #Клик кнопку "Створити"
    Click Button    ${locator_button_create_item}

Информация по позиции

Информация по закупке
    [Arguments]    ${enquiryPeriod}    ${tenderPeriod}    ${tender_data}
    #Ввод названия тендера
    ${descr}=    Get From Dictionary    ${tender_data.data}    title
    Input Text    ${locator_tenderTitle}    ${descr}
    Define angular    purchase    title    ${descr}
    #Выбор НДС
    ${PDV}=    Get From Dictionary    ${tender_data.data.value}    valueAddedTaxIncluded
    Click Element    ${locator_pdv}
    Execute Javascript    window.scroll(1000, 1000)
    #Валюта
    Wait Until Element Is Enabled    ${locator_currency}    15
    Click Element    ${locator_currency}
    ${currency}=    Get From Dictionary    ${tender_data.data.value}    currency
    Select From List By Label    ${locator_currency}    ${currency}
    Comment    Input Text    ${locator_currency}    ${currency}
    Comment    Execute Javascript    var ttt=angular.element(document.getElementById('title')).scope();ttt.purchase.title="${descr}";
    #Ввод бюджета
    ${budget}=    Get From Dictionary    ${tender_data.data.value}    amount
    ${text}=    Convert To string    ${budget}
    Comment    Log To Console    ${text}
    ${text}=    String.Replace String    ${text}    .    ,
    Input Text    ${locator_budget}    ${text}
    Comment    Execute Javascript    var ttt=angular.element(document.getElementById('budget')).scope();ttt.budget="${budget}";
    Define angular    purchase    budget    ${text}
    #Ввод мин шага
    ${min_step}=    Get From Dictionary    ${tender_data.data.minimalStep}    amount
    ${text_ms}=    Convert To string    ${min_step}
    ${text_ms}=    String.Replace String    ${text_ms}    .    ,
    Input Text    ${locator_min_step}    ${text_ms}
    Comment    Execute Javascript    var ttt=angular.element(document.getElementById('min_step')).scope();ttt.purchase.minStep="${min_step}";
    Define angular    purchase    min_step    ${text_ms}
    #Период уточнений нач дата
    ${enquiry_start}=    Get From Dictionary    ${enquiryPeriod}    startDate
    ${date_time_enq_st}=    dt    ${enquiry_start}
    Comment    ${js}=    Set Variable    $('#period_enquiry_start').datetimepicker({});
    Comment    Log To Console    $('#period_enquiry_start').datetimepicker({});
    Comment    Execute Javascript    ${js}
    Comment    Input Text    ${locator_discussionDate_start}    ${date_time}
    sleep    3
    #Период уточнений кон дата
    ${enquiry end}=    Get From Dictionary    ${enquiryPeriod}    endDate
    ${date_time_enq_end}=    dt    ${enquiry end}
    Comment    Input Text    ${locator_discussionDate_end}    ${date_time}
    Comment    Execute Javascript    ${js}    $('#period_enquiry_end').datetimepicker({});
    Comment    Execute Javascript    var ttt=angular.element(document.getElementById('period_enquiry_end')).scope();ttt.purchase.periodEnquiry.end="${date_time}";
    Comment    Define angular date end    purchase    period_enquiry_end    ${date_time_enq_end}    periodEnquiry
    sleep    3
    Define angular date    purchase    period_enquiry_start    ${date_time_enq_st}    ${date_time_enq_end}    periodEnquiry
    #Период приема предложений (нач дата)
    ${tender_start}=    Get From Dictionary    ${tenderPeriod}    startDate
    ${date_time_ten_st}=    dt    ${tender_start}
    Comment    Input Text    ${locator_bidDate_start}    ${date_time}
    Comment    Execute Javascript    ${js}    $('#period_tender_start').datetimepicker({});
    Comment    Execute Javascript    var ttt=angular.element(document.getElementById('period_tender_start)).scope();ttt.purchase.periodTender.start="${date_time}";
    Comment    Define angular date start    purchase    period_tender_start    ${date_time_ten_st}    periodTender
    sleep    3
    #Период приема предложений (кон дата)
    ${tender_end}=    Get From Dictionary    ${tenderPeriod}    endDate
    ${date_time_ten_end}=    dt    ${tender_end}
    Comment    Input Text    ${locator_bidDate_end}    ${date_time}
    Comment    Execute Javascript    ${js}    $('#period_tender_end').datetimepicker({});
    Comment    sleep    500000
    Comment    Define angular date end    purchase    period_tender_end    ${date_time_ten_end}    periodTender
    sleep    3
    Comment    Execute Javascript    var ttt=angular.element(document.getElementById('period_enquiry_start')).scope();ttt.purchase.periodEnquiry={};ttt.purchase.periodEnquiry.start="${date_time_enq_st}";ttt.purchase.periodEnquiry.end="${date_time_enq_end}";ttt.purchase.periodTender = {}; ttt.purchase.periodTender.start="${date_time_ten_st}";ttt.purchase.periodTender.end="${date_time_ten_end}";
    Define angular date    purchase    period_enquiry_start    ${date_time_ten_st}    ${date_time_ten_end}    periodTender
    Click Button    ${locator_button_next_step}
    #$('#period_tender_start').val('${date_time}');

Login
    [Arguments]    ${user}
    Wait Until Element Is Visible    ${locator_cabinetEnter}    10
    Click Element    ${locator_cabinetEnter}
    Click Element    ${locator_enter}
    Wait Until Element Is Visible    ${locator_emailField}    10
    Input Text    ${locator_emailField}    ${user.login}
    Input Text    ${locator_passwordField}    ${user.password}
    Click Element    ${locator_loginButton}
