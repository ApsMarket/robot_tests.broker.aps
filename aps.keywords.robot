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
    Click Link    ${locator_create_dop_zak}
    Wait Until Page Contains Element    ${locator_tenderTitle}
    Информация по закупке    ${tender_data}
    ${trtte}=    Get From Dictionary    ${tender_data}    data
    ${ttt}=    Get From Dictionary    ${trtte}    items
    ${item}=    Get From List    ${ttt}    0
    Добавить позицию    ${item}
    Click Button    ${locator_end_edit}
    Wait Until Element Is Enabled    ${locator_public}
    Click Button    ${locator_public}

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
    Wait Until Element Is Enabled    ${locator_items}
    Click Element    ${locator_items}
    Wait Until Element Is Enabled    ${locator_add_item_button}
    Click Button    ${locator_add_item_button}
    Wait Until Element Is Enabled    ${locator_item_description}
    #Название предмета закупки
    ${add_classif}=    Get From Dictionary    ${item}    description
    Press Key    ${locator_item_description}    ${add_classif}
    #Количество товара
    ${editItemQuant}=    Get From Dictionary    ${item}    quantity
    Wait Until Element Is Enabled    ${locator_Quantity}
    Press Key    ${locator_Quantity}    '${editItemQuant}'
    Log To Console    ${editItemQuant}
    #Выбор ед измерения
    Wait Until Element Is Enabled    ${locator_code}
    ${code}=    Get From Dictionary    ${item.unit}    code
    Select From List By Value    ${locator_code}    ${code}
    #Выбор ДК
    Click Button    ${locator_button_add_cpv}
    Wait Until Element Is Enabled    ${locator_cpv_search}
    ${cpv}=    Get From Dictionary    ${item.classification}    id
    sleep     3
    Press Key    ${locator_cpv_search}    ${cpv}
    Wait Until Element Is Enabled    xpath=.//*[@id='tree']
    Click Button    ${locator_add_classfier}
    #Выбор др ДК
    Wait Until Element Is Enabled    ${locator_button_add_dkpp}
    Click Button    ${locator_button_add_dkpp}
    Wait Until Element Is Visible    ${locator_dkpp_search}
    Clear Element Text    ${locator_dkpp_search}
    ${dkpp_q}=    Get From Dictionary    ${item}    additionalClassifications
    ${dkpp_w}=    Get From List    ${dkpp_q}    0
    ${dkpp}=    Get From Dictionary    ${dkpp_w}    id
    sleep    3
    Log To Console    ${dkpp}
    Press Key    ${locator_dkpp_search}    ${dkpp}
    Click Button    ${locator_add_classfier}
    #Срок поставки (конечная дата)
    ${delivery_Date}=    Get From Dictionary    ${item.deliveryDate}    endDate
    ${date_time}=    dt    ${delivery_Date}
    Click Element At Coordinates    ${locator_date_delivery_end}    -200    -10
    Press Key    ${locator_date_delivery_end}    ${date_time}
    Log To Console    ${date_time}
    Click Element    ${locator_check_location}
    Execute Javascript    window.scroll(1000, 1000)
    #Выбор страны
    ${country}=    Get From Dictionary    ${item.deliveryAddress}    countryName
    Select From List By Label    ${locator_country_id}    ${country}
    Log To Console    ${country}
    Execute Javascript    window.scroll(1000, 1000)
    ${region}=    Get From Dictionary    ${item.deliveryAddress}    region
    Select From List By Label    ${locator_SelectRegion}    ${region}
    Log To Console    ${region}
    ${post_code}=    Get From Dictionary    ${item.deliveryAddress}    postalCode
    Press Key    ${locator_postal_code}    ${post_code}
    ${locality}=    Get From Dictionary    ${item.deliveryAddress}    locality
    Press Key    ${locator_locality}    ${locality}
    ${street}=    Get From Dictionary    ${item.deliveryAddress}    streetAddress
    Press Key    ${locator_street}    ${street}
    ${deliveryLocation_latitude}=    Get From Dictionary    ${item.deliveryLocation}    latitude
    ${deliveryLocation_latitude}    Convert To String    ${deliveryLocation_latitude}
    ${deliveryLocation_latitude}    String.Replace String    ${deliveryLocation_latitude}    decimal    string
    Press Key    ${locator_deliveryLocation_latitude}    ${deliveryLocation_latitude}
    ${deliveryLocation_longitude}=    Get From Dictionary    ${item.deliveryLocation}    longitude
    ${deliveryLocation_longitude}=    Convert To String    ${deliveryLocation_longitude}
    ${deliveryLocation_longitude}=    String.Replace String    ${deliveryLocation_longitude}    decimal    string
    Press Key    ${locator_deliveryLocation_longitude}    ${deliveryLocation_longitude}
    Log To Console    ${deliveryLocation_longitude}
    sleep    2
    #Клик кнопку "Створити"
    Click Button    ${locator_button_create_item}
    sleep    5

Информация по позиции

Информация по закупке
    [Arguments]    ${tender_data}
    #Ввод названия тендера
    ${descr}=    Get From Dictionary    ${tender_data.data}    title
    Input Text    ${locator_tenderTitle}    ${descr}
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
    ${text}=    Convert To string    ${budget}
    ${text}=    String.Replace String    ${text}    .    ,
    Press Key    ${locator_budget}    ${text}
    #Ввод мин шага
    ${min_step}=    Get From Dictionary    ${tender_data.data.minimalStep}    amount
    ${text_ms}=    Convert To string    ${min_step}
    ${text_ms}=    String.Replace String    ${text_ms}    .    ,
    Press Key    ${locator_min_step}    ${text_ms}
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
    Click Element At Coordinates    ${locator_discussionDate_start}    -100    -10
    Press Key    ${locator_discussionDate_start}    ${date_time_enq_st}
    Click Element At Coordinates    ${locator_discussionDate_end}    -100    -10
    Press Key    ${locator_discussionDate_end}    ${date_time_enq_end}
    Click Element At Coordinates    ${locator_bidDate_start}    -100    -10
    Press Key    ${locator_bidDate_start}    ${date_time_ten_st}
    Click Element At Coordinates    ${locator_bidDate_end}    -100    -10
    Press Key    ${locator_bidDate_end}    ${date_time_ten_end}
    Click Element    id=createOrUpdatePurchase
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

Добавить документ
    [Arguments]    ${filepath}
    Click Element    ${locator_documents}
    Wait Until Element Is Enabled    ${locator_add_ documents}
    Click Element    ${locator_add_ documents}
    Select From List By Label    ${locator_category}    empty
    Select From List By Value    ${locator_add_documents_to}    Tender
    Click Button    ${locator_download}
    Choose File    ${locator_input_download}    /home/ova/LICENSE for test.txt
    Click Button    ${locator_save_document}
