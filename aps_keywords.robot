*** Settings ***
Library           String
Library           Collections
Library           Selenium2Library
Resource          ../../op_robot_tests/tests_files/keywords.robot
Resource          ../../op_robot_tests/tests_files/resource.robot
Resource          Locators.robot
Library           DateTime
Library           conv_timeDate.py

*** Keywords ***
Открыть форму создания тендера
    Comment    Go To    http://192.168.90.170/purchase/create/0
    Wait Until Element Is Visible    ${locator_create_dop_zak}    8
    Click Element    ${locator_create_dop_zak}

Работа с жалобами

Переговорная мультилотовая процедура
    [Arguments]    ${tender_data}
    Wait Until Element Is Visible    ${locator_button_create}    15
    Click Button    ${locator_button_create}
    Wait Until Element Is Enabled    ${locator_create_negotiation}    15
    Click Link    ${locator_create_negotiation}
    Wait Until Page Contains Element    ${locator_tenderTitle}
    Info Negotiate    ${tender_data}
    ${trtte}=    Get From Dictionary    ${tender_data}    data
    ${ttt}=    Get From Dictionary    ${trtte}    items
    ${item}=    Get From List    ${ttt}    0
    Add item negotiate    ${item}    00
    Wait Until Element Is Visible    ${locator_add_item_button}
    Add item negotiate    ${item}    01
    Wait Until Page Contains Element    ${locator_toast_container}
    Click Button    ${locator_toast_close}
    Wait Until Element Is Enabled    ${locator_finish_edit}
    Click Button    ${locator_finish_edit}
    Wait Until Page Contains Element    ${locator_publish_tender}
    Wait Until Element Is Enabled    ${locator_publish_tender}
    Click Button    ${locator_publish_tender}

Открытые торги с публикацией на укр
    [Arguments]    ${tender}
    Wait Until Element Is Enabled    ${locator_button_create}    15
    Click Button    ${locator_button_create}
    Wait Until Element Is Enabled    ${locator_biddingUkr_create}    15
    Click Link    ${locator_biddingUkr_create}
    Info OpenUA    ${tender}
    ${ttt}=    Get From Dictionary    ${tender.data}    items
    ${item}=    Set Variable    ${ttt[0]}
    Add Item    ${item}    00
    Run Keyword And Return    Publish tender

Открытые торги с публикацией на англ

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
    Add Item    ${item}    00
    ${tender_UID}=    Publish tender
    [Return]    ${tender_UID}

date_Time
    [Arguments]    ${date}
    ${DT}=    Convert Date    ${date}    date_format=
    Return From Keyword    '${DT.day}'+'.'+'${DT.month}'+'.'+'${DT.year}'+' '+'${DT.hour}'+':'+'${DT.minute}'
    [Return]    ${aps_date}

Add Item
    [Arguments]    ${item}    ${d}
    Log To Console    item add start
    Wait Until Element Is Not Visible    xpath=.//div[@class="page-loader animated fadeIn"]    10
    sleep    2
    #Клик доб позицию
    Wait Until Element Is Enabled    ${locator_add_item_button}    30
    Click Element    ${locator_items}
    Click Button    ${locator_add_item_button}
    Wait Until Element Is Enabled    ${locator_item_description}${d}    30
    #Название предмета закупки
    ${add_classif}=    Get From Dictionary    ${item}    description
    Input Text    ${locator_item_description}${d}    ${add_classif}
    Comment    Press Key    ${locator_item_description}    ${add_classif}
    #Количество товара
    ${editItemQuant}=    Get From Dictionary    ${item}    quantity
    Wait Until Element Is Enabled    ${locator_Quantity}${d}
    Press Key    ${locator_Quantity}${d}    '${editItemQuant}'
    #Выбор ед измерения
    Wait Until Element Is Enabled    ${locator_code}${d}
    ${code}=    Get From Dictionary    ${item.unit}    code
    Select From List By Value    ${locator_code}${d}    ${code}
    ${name}=    Get From Dictionary    ${item.unit}    name
    #Выбор ДК
    Click Button    ${locator_button_add_cpv}
    Wait Until Element Is Enabled    ${locator_cpv_search}
    ${cpv}=    Get From Dictionary    ${item.classification}    id
    Press Key    ${locator_cpv_search}    ${cpv}
    Wait Until Element Is Enabled    //*[@id='tree']//li[@aria-selected="true"]    30
    Wait Until Element Is Enabled    ${locator_add_classfier}
    Click Button    ${locator_add_classfier}
    #Выбор др ДК
    sleep    1
    Wait Until Element Is Enabled    ${locator_button_add_dkpp}
    Click Button    ${locator_button_add_dkpp}
    Wait Until Element Is Visible    ${locator_dkpp_search}
    Clear Element Text    ${locator_dkpp_search}
    Press Key    ${locator_dkpp_search}    000
    Wait Until Element Is Enabled    //*[@id='tree']//li[@aria-selected="true"]    30
    Wait Until Element Is Enabled    ${locator_add_classfier}
    Click Button    ${locator_add_classfier}
    Wait Until Element Is Not Visible    xpath=//div[@class="modal-backdrop fade"]
    #Срок поставки (начальная дата)
    ${delivery_Date_start}=    Get From Dictionary    ${item.deliveryDate}    startDate
    ${date_time}=    dt    ${delivery_Date_start}
    Fill Date    ${locator_date_delivery_start}${d}    ${date_time}
    #Срок поставки (конечная дата)
    ${delivery_Date}=    Get From Dictionary    ${item.deliveryDate}    endDate
    ${date_time}=    dt    ${delivery_Date}
    Fill Date    ${locator_date_delivery_end}${d}    ${date_time}
    Execute Javascript    window.scroll(0, 1000)
    Click Element    xpath=.//*[@id='is_delivary_${d}']/div[1]/div[2]/div
    #Выбор страны
    ${country}=    Get From Dictionary    ${item.deliveryAddress}    countryName
    Select From List By Label    xpath=.//*[@id='select_countries${d}']['Україна']    ${country}
    ${post_code}=    Get From Dictionary    ${item.deliveryAddress}    postalCode
    Press Key    ${locator_postal_code}${d}    ${post_code}
    Wait Until Element Is Not Visible    xpath=.//div[@class="page-loader animated fadeIn"]    10
    ${region}=    Get From Dictionary    ${item.deliveryAddress}    region
    Select From List By Label    ${locator_region}${d}    ${region}
    Execute Javascript    window.scroll(1000, 1000)
    ${street}=    Get From Dictionary    ${item.deliveryAddress}    streetAddress
    Press Key    ${locator_street}${d}    ${street}
    ${locality}=    Get From Dictionary    ${item.deliveryAddress}    locality
    Press Key    ${locator_locality}${d}    ${locality}
    #Koordinate
    ${deliveryLocation_latitude}=    Get From Dictionary    ${item.deliveryLocation}    latitude
    ${deliveryLocation_latitude}    Convert To String    ${deliveryLocation_latitude}
    ${deliveryLocation_latitude}    String.Replace String    ${deliveryLocation_latitude}    decimal    string
    Press Key    ${locator_deliveryLocation_latitude}${d}    ${deliveryLocation_latitude}
    ${deliveryLocation_longitude}=    Get From Dictionary    ${item.deliveryLocation}    longitude
    ${deliveryLocation_longitude}=    Convert To String    ${deliveryLocation_longitude}
    ${deliveryLocation_longitude}=    String.Replace String    ${deliveryLocation_longitude}    decimal    string
    Press Key    ${locator_deliveryLocation_longitude}${d}    ${deliveryLocation_longitude}
    #Клик кнопку "Створити"
    Wait Until Element Is Enabled    ${locator_button_create_item}${d}
    Click Button    ${locator_button_create_item}${d}

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
    Fill Date    ${locator_discussionDate_start}    ${date_time_enq_st}
    Fill Date    ${locator_discussionDate_end}    ${date_time_enq_end}
    Fill Date    ${locator_bidDate_start}    ${date_time_ten_st}
    Fill Date    ${locator_bidDate_end}    ${date_time_ten_end}
    Click Element    id=createOrUpdatePurchase
    Click Button    ${locator_button_next_step}

Info Negotiate
    [Arguments]    ${tender_data}
    #Ввод названия закупки
    ${title}=    Get From Dictionary    ${tender_data.data}    title
    Press Key    ${locator_tenderTitle}    ${title}
    #Примечания
    ${description}=    Get From Dictionary    ${tender_data.data}    description
    Press Key    ${locator_description}    ${description}
    #Условие применения переговорной процедуры
    ${select_directory_causes}=    Get From Dictionary    ${tender_data.data}    cause
    Select From List By Value    ${locator_select_directory_causes}    ${select_directory_causes}
    Press Key    ${locator_select_directory_causes}    ${select_directory_causes}
    #Обоснование
    ${cause_description}=    Get From Dictionary    ${tender_data.data}    causeDescription
    Press Key    ${locator_cause_description}    ${cause_description}
    #Выбор НДС
    ${PDV}=    Get From Dictionary    ${tender_data.data.value}    valueAddedTaxIncluded
    Click Element    ${locator_pdv}
    #Валюта
    Wait Until Element Is Enabled    ${locator_currency}    15
    ${currency}=    Get From Dictionary    ${tender_data.data.value}    currency
    Select From List By Label    ${locator_currency}    ${currency}
    Press Key    ${locator_currency}    ${currency}
    #Стоимость закупки
    ${budget}=    Get From Dictionary    ${tender_data.data.value}    amount
    ${text}=    Convert To string    ${budget}
    ${text}=    String.Replace String    ${text}    .    ,
    Press Key    ${locator_budget}    ${text}
    Click Button    ${locator_next_step}

Login
    [Arguments]    ${user}
    Wait Until Element Is Visible    ${locator_cabinetEnter}    10
    Click Element    ${locator_cabinetEnter}
    Click Element    ${locator_enter}
    Wait Until Element Is Visible    ${locator_emailField}    10
    Input Text    ${locator_emailField}    ${user.login}
    Input Text    ${locator_passwordField}    ${user.password}
    Click Element    ${locator_loginButton}

Load document
    [Arguments]    ${filepath}
    Run Keyword And Ignore Error    Wait Until Page Does Not Contain Element    xpath=.//div[@class="page-loader animated fadeIn"]
    Wait Until Element Is Enabled    ${locator_documents}    \    5
    Click Element    ${locator_documents}
    Wait Until Page Contains Element    ${locator_add_ documents}
    Wait Until Element Is Enabled    ${locator_add_ documents}
    Click Element    ${locator_add_ documents}
    Wait Until Element Is Enabled    ${locator_documents}
    Click Element    ${locator_documents}
    Click Element    ${locator_category}
    Wait Until Page Contains Element    ${locator_category}
    Wait Until Element Is Enabled    ${locator_category}
    Select From List By Label    ${locator_category}    Повідомлення про закупівлю
    Click Element    ${locator_add_documents_to}
    Select From List By Value    ${locator_add_documents_to}    Tender
    Wait Until Page Contains Element    ${locator_download}
    Choose File    ${locator_download}    ${filepath}
    Click Button    ${locator_save_document}

Search tender
    [Arguments]    ${username}    ${tender_uaid}
    Wait Until Page Contains Element    ${locator_search_type}
    Select From List By Label    ${locator_search_type}    По Id
    Wait Until Page Contains Element    ${locator_input_search}
    Wait Until Element Is Enabled    ${locator_input_search}
    Input Text    ${locator_input_search}    ${tender_uaid}
    Wait Until Element Is Enabled    ${locator_search-btn}
    Click Element    ${locator_search-btn}
    Wait Until Page Contains Element    xpath=.//*[@id='purchase-page']/div/div//*[@class="spanProzorroId"][text()="${tender_uaid}"]    30
    Click Element    xpath=.//*[@id='purchase-page']/div/div//*[@class="spanProzorroId"][text()="${tender_uaid}"]/../../../../../div/div/div/h4

Info OpenUA
    [Arguments]    ${tender}
    Log To Console    start openUa info
    #Ввод названия закупки
    Wait Until Page Contains Element    ${locator_tenderTitle}
    ${descr}=    Get From Dictionary    ${tender.data}    title
    Input Text    ${locator_tenderTitle}    ${descr}
    #Выбор НДС
    ${PDV}=    Get From Dictionary    ${tender.data.value}    valueAddedTaxIncluded
    Click Element    ${locator_pdv}
    Execute Javascript    window.scroll(1000, 1000)
    #Валюта
    Wait Until Element Is Enabled    ${locator_currency}    15
    Click Element    ${locator_currency}
    ${currency}=    Get From Dictionary    ${tender.data.value}    currency
    Select From List By Label    ${locator_currency}    ${currency}
    #Ввод бюджета
    ${budget}=    Get From Dictionary    ${tender.data.value}    amount
    ${text}=    Convert To string    ${budget}
    ${text}=    String.Replace String    ${text}    .    ,
    Press Key    ${locator_budget}    ${text}
    #Ввод мин шага
    ${min_step}=    Get From Dictionary    ${tender.data.minimalStep}    amount
    ${text_ms}=    Convert To string    ${min_step}
    ${text_ms}=    String.Replace String    ${text_ms}    .    ,
    Press Key    ${locator_min_step}    ${text_ms}
    #Период приема предложений (кон дата)
    ${tender_end}=    Get From Dictionary    ${tender.data.tenderPeriod}    endDate
    ${date_time_ten_end}=    dt    ${tender_end}
    Fill Date    ${locator_bidDate_end}    ${date_time_ten_end}
    Click Element    id=createOrUpdatePurchase
    Wait Until Element Is Enabled    ${locator_button_next_step}    20
    Click Button    ${locator_button_next_step}
    Log To Console    finish openUa info

Add item negotiate
    [Arguments]    ${item}    ${q}
    #Клик доб позицию
    Wait Until Element Is Enabled    ${locator_items}    30
    Click Element    ${locator_items}
    Wait Until Element Is Enabled    ${locator_add_item_button}
    Click Button    ${locator_add_item_button}
    Wait Until Element Is Enabled    ${locator_item_description}${q}
    #Название предмета закупки
    ${add_classif}=    Get From Dictionary    ${item}    description
    Press Key    ${locator_item_description}${q}    ${add_classif}
    #Количество товара
    ${editItemQuant}=    Get From Dictionary    ${item}    quantity
    Wait Until Element Is Enabled    ${locator_Quantity}${q}
    Input Text    ${locator_Quantity}${q}    ${editItemQuant}
    #Выбор ед измерения
    Wait Until Element Is Enabled    ${locator_code}${q}
    ${code}=    Get From Dictionary    ${item.unit}    code
    Select From List By Value    ${locator_code}${q}    ${code}
    ${name}=    Get From Dictionary    ${item.unit}    name
    #Выбор ДК
    Click Button    ${locator_button_add_cpv}
    Wait Until Element Is Enabled    ${locator_cpv_search}
    ${cpv}=    Get From Dictionary    ${item.classification}    id
    Press Key    ${locator_cpv_search}    ${cpv}
    Wait Until Element Is Enabled    //*[@id='tree']//li[@aria-selected="true"]    30
    Wait Until Element Is Enabled    ${locator_add_classfier}
    Click Button    ${locator_add_classfier}
    #Выбор др ДК
    sleep    1
    Wait Until Element Is Enabled    ${locator_button_add_dkpp}
    Click Button    ${locator_button_add_dkpp}
    Wait Until Element Is Visible    ${locator_dkpp_search}
    Clear Element Text    ${locator_dkpp_search}
    Input Text    ${locator_dkpp_search}    000
    Wait Until Element Is Enabled    //*[@id='tree']//li[@aria-selected="true"]    30
    Wait Until Element Is Enabled    ${locator_add_classfier}
    Click Button    ${locator_add_classfier}
    #Срок поставки (начальная дата)
    sleep    10
    ${delivery_Date_start}=    Get From Dictionary    ${item.deliveryDate}    startDate
    ${date_time}=    dt    ${delivery_Date_start}
    Fill Date    ${locator_date_delivery_start}${q}    ${date_time}
    #Срок поставки (конечная дата)
    ${delivery_Date}=    Get From Dictionary    ${item.deliveryDate}    endDate
    ${date_time}=    dt    ${delivery_Date}
    Fill Date    ${locator_date_delivery_end}${q}    ${date_time}
    Comment    Click Element    ${locator_check_location}
    Execute Javascript    window.scroll(1000, 1000)
    #Выбор страны
    ${country}=    Get From Dictionary    ${item.deliveryAddress}    countryName
    Select From List By Label    ${locator_country_id}${q}    ${country}
    Execute Javascript    window.scroll(1000, 1000)
    #Выбор региона
    sleep    5
    ${region}=    Get From Dictionary    ${item.deliveryAddress}    region
    Select From List By Label    ${locator_SelectRegion}${q}    ${region}
    #Индекс
    ${post_code}=    Get From Dictionary    ${item.deliveryAddress}    postalCode
    Press Key    ${locator_postal_code}${q}    ${post_code}
    ${locality}=    Get From Dictionary    ${item.deliveryAddress}    locality
    Press Key    ${locator_locality}${q}    ${locality}
    ${street}=    Get From Dictionary    ${item.deliveryAddress}    streetAddress
    Press Key    ${locator_street}${q}    ${street}
    sleep    3
    Click Element    xpath=.//*[@id='is_delivary_00']/div[1]/div[2]/div
    ${deliveryLocation_latitude}=    Get From Dictionary    ${item.deliveryLocation}    latitude
    ${deliveryLocation_latitude}    Convert To String    ${deliveryLocation_latitude}
    ${deliveryLocation_latitude}    String.Replace String    ${deliveryLocation_latitude}    decimal    string
    Press Key    ${locator_deliveryLocation_latitude}${q}    ${deliveryLocation_latitude}
    ${deliveryLocation_longitude}=    Get From Dictionary    ${item.deliveryLocation}    longitude
    ${deliveryLocation_longitude}=    Convert To String    ${deliveryLocation_longitude}
    ${deliveryLocation_longitude}=    String.Replace String    ${deliveryLocation_longitude}    decimal    string
    Press Key    ${locator_deliveryLocation_longitude}${q}    ${deliveryLocation_longitude}
    sleep    2
    #Клик кнопку "Створити"
    Click Button    ${locator_button_create_item}${q}
    sleep    2

Publish tender
    Log To Console    start punlish tender
    Wait Until Page Contains Element    ${locator_toast_container}
    Click Button    ${locator_toast_close}
    Wait Until Element Is Enabled    ${locator_finish_edit}
    Click Button    ${locator_finish_edit}
    Wait Until Page Contains Element    ${locator_publish_tender}
    Wait Until Element Is Enabled    ${locator_publish_tender}
    Click Button    ${locator_publish_tender}
    Wait Until Page Contains Element    ${locator_UID}
    ${tender_UID}=    Execute Javascript    var model=angular.element(document.getElementById('header')).scope(); \ return model.$$childHead.purchase.purchase.prozorroId
    Log To Console    finish punlish tender ${tender_UID}
    Return From Keyword    ${tender_UID}
    [Return]    ${tender_UID}

Add question
    [Arguments]    ${tender_data}
    Select From List By Label    ${locator_question_to}    0
    ${title}=    Get From Dictionary    ${tender_data.data}    title
    Press Key    ${locator_question_title}    ${title}
    ${description}=    Get From Dictionary    ${tender_data.data}    description
    Press Key    ${locator_description_question}    ${description}

Fill Date
    [Arguments]    ${id}    ${value}
    ${id}    Replace String    ${id}    id=    ${EMPTY}
    ${ddd}=    Set Variable    SetDateTimePickerValue(\'${id}\',\'${value}\');
    Execute Javascript    ${ddd}
