*** Settings ***
Library           Selenium2Library
Library           String
Library           DateTime
Library           Collections
Library           Screenshot
Resource          APStender_subkeywords.robot
Library           aps_service.py

*** Variables ***
${item_index}     0
${locator.tenderID}    xpath=//span[@id='titleTenderCode']
${locatorDeals}    id=tab3
${locatot.cabinetEnter}    id=login_ribbon
${locator.emailField}    id=LoginBox
${locator.passwordField}    id=LoginPasswordBox
${locator.loginButton}    id=ButtonLogin
${locator.buttonTenderAdd}    xpath=//a[@href="tenderadd"]    #id=ButtonTenderAdd
${locator.tenderTitle}    id=edtTenderTitle
${locator.tenderDetail}    id=edtTenderDetail
${locator.tenderBudget}    id=edtTenderBudget
${locator.tenderStep}    id=edtMinStep
${locator.tenderComStart}    id=date_enquiry_start
${locator.tenderComEnd}    id=date_enquiry_end
${locator.tenderStart}    id=date_tender_start
${locator.tenderEnd}    id=date_tender_end
${locator.tenderAdd}    id=btnAdd
${locator.topSearch}    id=topsearch
${locator.searchButton}    id=btnSearch
${locator.findTender}    xpath=//p[@class='cut_title']
${locator.informationTable}    xpath=//li[@id='tab1']
${locator.title}    id=edtTenderTitle
${locator.descriptions}    id=edtTenderDetail
${locator.value.amount}    id=edtTenderBudget
${locator.tenderId}    id=titleTenderCode
${locator.procuringEntity.name}    id=author_legal_name
${locator.enquiryPeriod.startDate}    id=date_enquiry_start
${locator.enquiryPeriod.endDate}    id=date_enquiry_end
${locator.tenderPeriod.startDate}    id=date_tender_start
${locator.tenderPeriod.endDate}    id=date_tender_end
${locator.value.valueAddedTaxIncluded}    id=lblPDV
${locator.minimalStep.amount}    id=edtMinStep
${locator.items[0].deliveryLocation.latitude}    id=qdelivlatitude
${locator.items[0].deliveryLocation.longitude}    id=qdelivlongitude
${locator.items[0].deliveryAddress.postalCode}    id=qdelivaddrpost_code
${locator.items[0].deliveryAddress.countryName}    id=qdelivaddrcountry
${locator.items[0].deliveryAddress.locality}    id=qdeliv_addr_locality
${locator.items[0].deliveryAddress.streetAddress}    id=qdeliv_addrstreet
${locator.items[0].classification.scheme}    id=scheme2015
${locator.items[0].classification.id}    id=cpv_code
${locator.items[0].classification.description}    id=cpv_name
${locator.items[0].additionalClassifications[0].scheme}    id=scheme2010
${locator.items[0].additionalClassifications[0].id}    id=qdkpp_code
${locator.items[0].additionalClassifications[0].description}    id=qdkpp_name
${locator.items[0].description}    xpath=//div[@class="col-md-8 col-sm-8 col-xs-7"]
${locator.questions[0].title}    id=questionTitlespan1
${locator.questions[0].description}    id=label_question_description
${locator.questions[0].date}    xpath=//div[@class="col-md-2 text-right"][@style="font-size: 11px; color: black;"]
${locator.items[0].deliveryDate.endDate}    id=ddto
${locator.value.currency}    id=lblTenderCurrency2
${locator.items[0].deliveryAddress.region}    id=qdeliv_addr_region
${locator.items[0].unit.code}    id=measure_prozorro_code
${locator.items[0].unit.name}    id=measure_name
${locator.items[0].quantity}    id=quantity
${locator.questions[0].answer}    id=answer

*** Keywords ***
Підготувати дані для оголошення тендера
    [Arguments]    ${username}    ${tender_data}
    ${tender_data}=    adapt_procuringEntity    ${tender_data}
    [Return]    ${tender_data}

Підготувати клієнт для користувача
    [Arguments]    @{ARGUMENTS}
    [Documentation]    [Documentation] \ Відкрити брaузер, створити обєкт api wrapper, тощо
    ...    ... \ \ \ \ \ ${ARGUMENTS[0]} == \ username
    Open Browser    ${USERS.users['${ARGUMENTS[0]}'].homepage}    ${USERS.users['${ARGUMENTS[0]}'].browser}    alias=${ARGUMENTS[0]}
    Set Window Size    @{USERS.users['${ARGUMENTS[0]}'].size}
    Set Window Position    @{USERS.users['${ARGUMENTS[0]}'].position}
    Run Keyword If    '${ARGUMENTS[0]}'!= 'aps_Viewer'    Login    @{ARGUMENTS}

Створити тендер
    [Arguments]    @{ARGUMENTS}
    [Documentation]    [Documentation]
    ...    ... \ \ \ \ \ ${ARGUMENTS[0]} == \ username
    ...    ... \ \ \ \ \ ${ARGUMENTS[1]} == \ tender_data
    Switch Browser    ${ARGUMENTS[0]}
    Return From Keyword If    '${ARGUMENTS[0]}' != 'aps_Owner'
    ${tender_data}=    Get From Dictionary    ${ARGUMENTS[1]}    data
    #
    Click Element    ${locator.buttonTenderAdd}
    TenderInfo    ${tender_data}
    \    #
    Run Keyword If    '${TEST NAME}' == 'Можливість оголосити мультилотовий тендер'    Click Element    css=label.btn.btn-info
    Заповнити дати тендеру    ${tender_data.enquiryPeriod}    ${tender_data.tenderPeriod}
    \    #
    sleep    3
    Click Button    ${locator.tenderAdd}
    sleep    3
    \    #
    Execute Javascript    window.scroll(1500,1500)
    Capture Page Screenshot
    Run Keyword If    '${TEST NAME}' == 'Можливість оголосити однопредметний тендер'    Додати предмет    ${tender_data}    0    0
    Run Keyword If    '${TEST NAME}' == 'Можливість оголосити багатопредметний тендер'    Додати багато предметів    ${tender_data}
    Run Keyword If    '${TEST NAME}' == 'Можливість оголосити мультилотовий тендер'    Додати багато лотів    ${tender_data}
    \    #    #
    ${tender_UAid}=    Опублікувати тендер
    Reload Page
    [Return]    ${tender_UAid}

Завантажити документ
    [Arguments]    ${username}    ${filepath}    ${tender_UAid}
    aps.Пошук тендера по ідентифікатору    ${username}    ${tender_UAid}
    Click Button    ButtonTenderEdit
    Click Element    addFile
    Select From List By Label    category_of    Документи закупівлі
    Select From List By Label    file_of    тендеру
    InputText    TenderFileUpload    ${filepath}
    Click Link    lnkDownload
    Wait Until Element Is Enabled    addFile
    Click Element    id=btnPublishTop

Завантажити документ в лот
    [Arguments]    ${username}    ${filepath}    ${TENDER_UAID}    ${lot_id}
    aps.Пошук тендера по ідентифікатору    ${username}    ${TENDER_UAID}
    Log To Console    ${filepath}
    Click Button    ButtonTenderEdit
    Click Element    addFile
    Select From List By Label    category_of    Документи закупівлі
    Select From List By Label    file_of    лоту
    Wait Until Element Is Enabled    id=FileComboSelection2
    Log To Console    ${lot_id}
    #Select From List By Label    id=FileComboSelection2    ${lot_id}
    Choose File    id=TenderFileUpload    ${filepath}
    Click Link    id=lnkDownload
    Wait Until Element Is Enabled    addFile

Пошук тендера по ідентифікатору
    [Arguments]    ${username}    ${tender_UAid}
    [Documentation]    ${ARGUMENTS[0]} == username
    ...    ${ARGUMENTS[1]} == tenderId
    Run Keyword If    '${TEST NAME}' == 'Можливість знайти однопредметний тендер по ідентифікатору'    Sleep    80
    Run Keyword And Return If    '${username}' == 'aps_Viewer'    SearchIdViewer    ${tender_UAid}    ${username}
    Go To    ${USERS.users['${username}'].homepage}
    sleep    3
    Input text    id=topsearch    ${tender_UAid}
    Click Element    id=btnSearch
    Wait Until Page Contains    ${tender_UAid}    10
    Click Element    xpath=(//p[@class='cut_title'])[last()]
    sleep    5

Подати цінову пропозицію
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == username
    ...    ${ARGUMENTS[1]} == tenderId
    ...    ${ARGUMENTS[2]} == ${test_bid_data}
    Switch Browser    ${ARGUMENTS[0]}
    aps.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}
    Reload Page
    Click Element    ${locatorDeals}
    ${amount}=    Get From Dictionary    ${ARGUMENTS[2].data.value}    amount
    Input Text    id=editBid    ${amount}
    Click Element    id=addBidButton
    sleep    2
    Reload Page
    ${resp}=    Get Value    id=my_bid_id
    [Return]    ${resp}

Додати предмет закупівлі
    [Arguments]    ${username}    ${tenderID}    ${item}
    aps.Пошук тендера по ідентифікатору    ${username}    ${tenderID}
    Wait Until Page Contains Element    id=ButtonTenderEdit
    Click Element    id=ButtonTenderEdit
    Додати предмет    ${item}    0    0
    Click Element    id=btnPublishTop

Видалити предмет закупівлі
    aps.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}
    Wait Until Page Contains Element    id=ButtonTenderEdit    10
    Click Element    id=ButtonTenderEdit
    : FOR    ${INDEX}    IN RANGE    1    ${ARGUMENTS[2]}-1
    \    sleep    5
    \    Click Element    xpath=//a[@class='deleteMultiItem'][last()]
    \    sleep    5
    \    Click Element    xpath=//a[@class='jBtn green']
    Wait Until Page Contains Element    id=AddItemButton    30
    Click Element    id=AddItemButton

Скасувати цінову пропозицію
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == username
    ...    ${ARGUMENTS[1]} == none
    ...    ${ARGUMENTS[2]} == tenderId
    Switch Browser    ${ARGUMENTS[0]}
    aps.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}
    Wait Until Page Contains    Прийом пропозицій    10
    Click Element    id=tab3
    Wait Until Element Is Enabled    id=btnDeleteBid
    Click Element    id=btnDeleteBid
    Wait Until Page Contains Element    id=addBidButton

Login
    [Arguments]    @{ARGUMENTS}
    Wait Until Element Is Visible    ${locatot.cabinetEnter}    10
    Click Element    ${locatot.cabinetEnter}
    Wait Until Element Is Visible    ${locator.emailField}    10
    Input Text    ${locator.emailField}    ${USERS.users['${ARGUMENTS[0]}'].login}
    sleep    2
    Input Text    ${locator.passwordField}    ${USERS.users['${ARGUMENTS[0]}'].password}
    sleep    2
    Click Element    ${locator.loginButton}

Оновити сторінку з тендером
    [Arguments]    @{ARGUMENTS}
    [Documentation]    [Documentation]
    ...    ... \ \ \ \ \ ${ARGUMENTS[0]} = \ username
    ...    ... \ \ \ \ \ ${ARGUMENTS[1]} = \ ${TENDER_UAID}
    Switch Browser    ${ARGUMENTS[0]}
    Reload Page

Відображення бюджету оголошеного тендера
    ${return_value}=    Отримати текст із поля і показати на сторінці    id=edtTenderBudget

Отримати інформацію із тендера
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == username
    ...    ${ARGUMENTS[1]} == fieldname
    Switch browser    ${ARGUMENTS[0]}
    Run Keyword And Return    Отримати інформацію про ${ARGUMENTS[1]}

Отримати текст із поля і показати на сторінці
    [Arguments]    ${fieldname}
    sleep    3
    Wait Until Page Contains Element    ${locator.${fieldname}}    22
    Sleep    2
    ${return_value}=    Get Text    ${locator.${fieldname}}
    [Return]    ${return_value}

Отримати інформацію про title
    ${return_value}=    Отримати текст із поля і показати на сторінці    title
    ${return_value}=    Convert To String    ${return_value}
    [Return]    ${return_value}

Отримати інформацію про description
    ${return_value}=    Отримати текст із поля і показати на сторінці    descriptions
    [Return]    ${return_value}

Отримати інформацію про value.amount
    ${return_value}=    Отримати текст із поля і показати на сторінці    value.amount
    ${return_value}=    Replace String    ${return_value}    ,    .
    ${return_value}=    Convert To Number    ${return_value}
    [Return]    ${return_value}

Отримати інформацію про value.currency
    ${return_value}=    Отримати текст із поля і показати на сторінці    value.currency
    [Return]    ${return_value}

Отримати інформацію про value.valueAddedTaxIncluded
    ${value}=    Отримати текст із поля і показати на сторінці    value.valueAddedTaxIncluded
    ${return_value}=    Run Keyword And Return If    'без ПДВ.' == '${value}'    Set Variable    ${False}
    ${return_value}=    Run Keyword And Return If    'з ПДВ.' == '${value}'    Set Variable    ${True}
    [Return]    ${return_value}

Отримати інформацію про tenderID
    ${return_value}=    Отримати текст із поля і показати на сторінці    tenderId
    [Return]    ${return_value}

Отримати інформацію про procuringEntity.name
    ${return_value}=    Отримати текст із поля і показати на сторінці    procuringEntity.name
    [Return]    ${return_value}

Отримати інформацію про enquiryPeriod.startDate
    ${return_value}=    Отримати текст із поля і показати на сторінці    enquiryPeriod.startDate
    ${return_value}=    aps_service.parse_date    ${return_value}
    [Return]    ${return_value}

Отримати інформацію про enquiryPeriod.endDate
    ${return_value}=    Отримати текст із поля і показати на сторінці    enquiryPeriod.endDate
    ${return_value}=    aps_service.parse_date    ${return_value}
    [Return]    ${return_value}

Отримати інформацію про tenderPeriod.startDate
    ${return_value}=    Отримати текст із поля і показати на сторінці    tenderPeriod.startDate
    ${return_value}=    aps_service.parse_date    ${return_value}
    [Return]    ${return_value}

Отримати інформацію про tenderPeriod.endDate
    ${return_value}=    Отримати текст із поля і показати на сторінці    tenderPeriod.endDate
    ${return_value}=    aps_service.parse_date    ${return_value}
    [Return]    ${return_value}

Отримати інформацію про minimalStep.amount
    ${return_value}=    Отримати текст із поля і показати на сторінці    minimalStep.amount
    ${return_value}=    Replace String    ${return_value}    ,    .
    ${return_value}=    Convert To Number    ${return_value}
    [Return]    ${return_value}

Отримати інформацію про items[0].deliveryDate.endDate
    Click Element    xpath=//div[@class="col-md-8 col-sm-8 col-xs-7"]
    Capture Page Screenshot
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[0].deliveryDate.endDate
    ${return_value}=    aps_service.parse_date    ${return_value}
    [Return]    ${return_value}

Отримати інформацію про items[0].deliveryLocation.latitude
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[0].deliveryLocation.latitude
    ${return_value}=    Convert To Number    ${return_value}
    [Return]    ${return_value}

Отримати інформацію про items[0].deliveryLocation.longitude
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[0].deliveryLocation.longitude
    ${return_value}=    Convert To Number    ${return_value}
    [Return]    ${return_value}

Отримати інформацію про items[0].deliveryAddress.countryName
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[0].deliveryAddress.countryName
    [Return]    ${return_value}

Отримати інформацію про items[0].deliveryAddress.postalCode
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[0].deliveryAddress.postalCode
    [Return]    ${return_value}

Отримати інформацію про items[0].deliveryAddress.region
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[0].deliveryAddress.region
    [Return]    ${return_value}

Отримати інформацію про items[0].deliveryAddress.locality
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[0].deliveryAddress.locality
    [Return]    ${return_value}

Отримати інформацію про items[0].deliveryAddress.streetAddress
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[0].deliveryAddress.streetAddress
    [Return]    ${return_value}

Отримати інформацію про items[0].classification.scheme
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[0].classification.scheme
    ${return_value}=    Remove String    ${return_value}    :
    [Return]    ${return_value}

Отримати інформацію про items[0].classification.id
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[0].classification.id
    [Return]    ${return_value}

Отримати інформацію про items[0].classification.description
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[0].classification.description
    [Return]    ${return_value}

Отримати інформацію про items[0].additionalClassifications[0].scheme
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[0].additionalClassifications[0].scheme
    ${return_value}=    Remove String    ${return_value}    :
    [Return]    ${return_value}

Отримати інформацію про items[0].additionalClassifications[0].id
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[0].additionalClassifications[0].id
    [Return]    ${return_value}

Отримати інформацію про items[0].additionalClassifications[0].description
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[0].additionalClassifications[0].description
    [Return]    ${return_value}

Отримати інформацію про items[0].unit.name
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[0].unit.name
    [Return]    ${return_value}

Отримати інформацію про items[0].unit.code
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[0].unit.code
    [Return]    ${return_value}

Отримати інформацію про items[0].quantity
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[0].quantity
    ${return_value}=    Convert To Integer    ${return_value}
    [Return]    ${return_value}

Отримати інформацію про items[0].description
    [Arguments]    @{ARGUMENTS}
    ${return_value}=    Отримати текст із поля і показати на сторінці    items[0].description
    [Return]    ${return_value}

Задати питання
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == username
    ...    ${ARGUMENTS[1]} == tenderUaId
    ...    ${ARGUMENTS[2]} == questionId
    ${title}=    Get From Dictionary    ${ARGUMENTS[2].data}    title
    ${description}=    Get From Dictionary    ${ARGUMENTS[2].data}    description
    Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
    aps.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}
    sleep    3
    Wait Until Page Contains Element    xpath=//a[@href="#questions"]    20
    Click Element    xpath=//a[@href="#questions"]
    Wait Until Page Contains Element    id=addQuestButton    20
    Click Button    id=addQuestButton
    Input text    id=editQuestionTitle    ${title}
    Input text    id=editQuestionDetails    ${description}
    sleep    2
    Click Element    id=AddQuestion_Button
    Wait Until Page Contains    ${title}    30
    Capture Page Screenshot

Отримати інформацію про questions[0].title
    [Arguments]    @{ARGUMENTS[0]}
    sleep    120
    Reload Page
    Click Element    xpath=//a[@href="#questions"]
    sleep    2
    ${return_value}=    Отримати текст із поля і показати на сторінці    questions[0].title
    [Return]    ${return_value}

Отримати інформацію про questions[0].description
    Click Element    css=div.panel-title > div.row > div.col-md-9
    sleep    2
    ${return_value}=    Отримати текст із поля і показати на сторінці    questions[0].description
    [Return]    ${return_value}

Отримати інформацію про questions[0].date
    ${return_value}=    Отримати текст із поля і показати на сторінці    questions[0].date
    ${return_value}=    aps_service.parse_date    ${return_value}
    [Return]    ${return_value}

Відповісти на питання
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} = username
    ...    ${ARGUMENTS[1]} = tenderUaId
    ...    ${ARGUMENTS[2]} = 0
    ...    ${ARGUMENTS[3]} = answer_data
    sleep    120
    Reload Page
    ${answer}=    Get From Dictionary    ${ARGUMENTS[3].data}    answer
    Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
    aps.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}
    Wait Until Page Contains Element    xpath=//a[@href="#questions"]    20
    Click Element    xpath=//a[@href="#questions"]
    Sleep    2
    Click Element    css=div.panel-title > div.row > div.col-md-9
    Wait Until Page Contains Element    id=answerQuestion    20
    Sleep    4
    Click Element    id=answerQuestion
    Sleep    2
    Input text    id=editAnswerDetails    ${answer}
    Click Element    id=AddQuestionButton
    Sleep    2
    Reload Page
    Wait Until Page Contains    ${answer}    30
    Capture Page Screenshot

Змінити цінову пропозицію
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == username
    ...    ${ARGUMENTS[1]} == tenderId
    ...    ${ARGUMENTS[2]} == amount
    ...    ${ARGUMENTS[3]} == amount.value
    sleep    5
    Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
    aps.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}
    Click Element    id=tab3
    Click Element    id=btnDeleteBid
    Clear Element Text    id=editBid
    Input Text    id=editBid    ${ARGUMENTS[3]}
    sleep    3
    Click Element    id=addBidButton
    Wait Until Page Contains    Ви подали пропозицію. Очікуйте посилання на аукціон.

Внести зміни в тендер
    [Arguments]    @{ARGUMENTS}
    sleep    10
    Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
    aps.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}
    Sleep    2
    Click Element    id=ButtonTenderEdit
    Sleep    2
    Input text    id=edtTenderTitle    ${ARGUMENTS[2]}
    Sleep    2
    Click Element    id=btnPublishTop
    Wait Until Page Contains Element    ${ARGUMENTS[2]}    15
    Click Element    id=btnView
    Capture Page Screenshot

Отримати інформацію про questions[0].answer
    sleep    120
    Reload Page
    Click Element    id=tab2
    Click Element    css=div.panel-title > div.row > div.col-md-9
    ${return_value}=    Отримати текст із поля і показати на сторінці    questions[0].answer
    [Return]    ${return_value}

Завантажити документ в ставку
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[1]} == file
    ...    ${ARGUMENTS[2]} == tenderId
    sleep    10
    Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
    Click Element    ${locatorDeals}
    Sleep    2
    Choose File    id=BidFileUpload    ${ARGUMENTS[1]}
    sleep    2
    Click Element    xpath=.//*[@id='lnkDownload'][@class="btn btn-success"]

Змінити документ в ставці
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == username
    ...    ${ARGUMENTS[1]} == file
    ...    ${ARGUMENTS[2]} == tenderId
    sleep    10
    Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
    Sleep    2
    Click Element    id=deleteBidFileButton
    Click Element    id=Button6
    sleep    2
    Choose File    id=BidFileUpload    ${ARGUMENTS[1]}
    sleep    5
    Reload Page
    Click Element    xpath=.//*[@id='lnkDownload'][@class="btn btn-success"]

Отримати посилання на аукціон для глядача
    [Arguments]    @{ARGUMENTS}
    Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
    aps.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}
    Wait Until Page Contains    Аукціон    5
    ${url} =    Get Element Attribute    xpath=//a[@id="a_auction_url"]@href
    [Return]    ${url}

Отримати посилання на аукціон для учасника
    [Arguments]    @{ARGUMENTS}
    Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
    Click Element    xpath=//div[@id='bs-example-navbar-collapse-1']/div/div/a/img[2]
    Sleep    2
    Clear Element Text    id=topsearch
    Click Element    id=inprogress
    Input Text    id=topsearch    ${ARGUMENTS[1]}
    Click Element    id=btnSearch
    Click Element    xpath=//p[@class='cut_title']
    Capture Page Screenshot
    ${url}=    Get Element Attribute    xpath=//a[@id="labelAuction2"]@href
    [Return]    ${url}

Отримати інформацію про status
    Reload Page
    Sleep    5
    ${value}=    Get Text    id=labelTenderStatus
    # Provider
    Run Keyword And Return If    '${TEST NAME}' == 'Можливість подати цінову пропозицію першим учасником'    Active.tendering_provider    ${value}
    Run Keyword And Return If    '${TEST NAME}' == 'Можливість подати повторно цінову пропозицію першим учасником'    Active.tendering_provider    ${value}
    Run Keyword And Return If    '${TEST NAME}' == 'Можливість вичитати посилання на участь в аукціоні для першого учасника'    Active.auction_viewer    ${value}
    # Viewer
    Run Keyword And Return If    '${TEST NAME}' == 'Можливість вичитати посилання на аукціон для глядача'    Active.auction_viewer    ${value}
    [Return]    ${return_value}

Active.tendering_provider
    [Arguments]    ${value}
    Sleep    60
    ${return_value}=    Replace String    ${value}    Прийом пропозицій    active.tendering
    [Return]    ${return_value}

Active.auction_viewer
    [Arguments]    ${value}
    Sleep    60
    ${return_value}=    Replace String    ${value}    Аукціон    active.auction
    [Return]    ${return_value}

Створити лот
    [Arguments]    ${username}    ${tender_uaid}    ${lot}
    aps.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
    Click Button    ButtonTenderEdit
    Click Element    id=AddLot
    ${txt_title}=    Get From Dictionary    ${lot.data}    title
    Input Text    lot_name    ${txt_title}
    ${txt}=    Get From Dictionary    ${lot.data}    description
    Input Text    lot_description    ${txt}
    ${txt}=    Get From Dictionary    ${lot.data.value}    amount
    ${txt}=    Convert To String    ${txt}
    Input Text    lot_budget    ${txt}
    ${txt}=    Get From Dictionary    ${lot.data.minimalStep}    amount
    ${txt}=    Convert To String    ${txt}
    Input Text    lot_auction_min_step    ${txt}
    Click Element    id=button_add_lot

Видалити лот
    [Arguments]    ${username}    ${tender_uaid}    ${lot_id}
    aps.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
    Click Element    xpath=.//*[@id='headingThree']/h4/div[1]/div[2]/p/b[contains(text(), "${lot_id}")]
    sleep    2
    Click Element    xpath=.//div/div/div[2]/div[2]/a
    sleep    3
    Input Text    id=reason_lot_cancel    Відміна лота
    Click Element    id=Button3

Змінити лот
    [Arguments]    ${username}    ${tender_uaid}    ${lot_id}    ${fieldname}    ${fieldvalue}
    Switch Browser    ${username}
    aps.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
    Click Button    ButtonTenderEdit
    Execute Javascript    window.scroll(1500,1500)
    sleep    3
    Click Element    xpath=.//*[@id='headingThree']/h4/div[1]/div[2]/p/b[contains(text(), "${lot_id}")]
    Click Element    ${lot.btnEditEdt}
    Wait Until Element Is Visible    xpath=.//*[@id='button_delete_lot']
    Input Text    id=lot_description    ${fieldvalue}
    Click Element    id=button_add_lot

Додати предмет закупівлі в лот
    [Arguments]    ${username}    ${tender_uaid}    ${lot_id}    ${item}
    aps.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
    Click Button    ButtonTenderEdit
    Додати предмет    ${item}    0    ${lot_id}
