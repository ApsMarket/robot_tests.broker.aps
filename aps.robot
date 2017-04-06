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

*** Keywords ***
Підготувати клієнт для користувача
    [Arguments]    ${username}
    [Documentation]    Відкриває переглядач на потрібній сторінці, готує api wrapper тощо
    ${user}=    Get From Dictionary    ${USERS.users}    ${username}
    Open Browser    ${user.homepage}    ${user.browser}
    Set Window Position    @{user.position}
    Log To Console    ${user.position}
    Set Window Size    @{user.size}
    Run Keyword If    '${role}'!='aps_Viewer'    Login    ${user}

aps.Адаптувати дані для оголошення тендера
    [Arguments]    ${username}    ${tender_data}
    [Documentation]    Змінює деякі поля в tender_data (автоматично згенерованих даних для оголошення тендера) згідно з особливостями майданчика
    [Return]    ${y}

aps.Створити тендер
    [Arguments]    ${g}    ${tender_data}
    [Documentation]    Створює однопредметний тендер
    Wait Until Element Is Visible    ${loc.ButtonTenderAdd}    5
    Click Element    ${loc.ButtonTenderAdd}
    Wait Until Element Is Visible    ${locator.buttonTenderAdd}    5
    Click Element    ${locator.buttonTenderAdd}
    Wait Until Page Contains Element    ${locator.tenderTitle}    10
    Click Element    ${locator.tenderTitle}
    Log To Console    до инф по закупке
    Информация по закупке    ${tender_data.data.enquiryPeriod}    ${tender_data.data.tenderPeriod}    ${tender_data}
    Execute Javascript    window.scroll(1000, 1000)
    Click Element    ${locator.tenderAdd}
    Execute Javascript    window.scroll(1000, 1000)
    ${trtte}=    Get From Dictionary    ${tender_data}    data
    Log To Console    ${trtte}
    ${ttt}=    Get From Dictionary    ${trtte}    items
    ${item}=    Get From List    ${ttt}    0
    Log To Console    До добавления позиции
    Добавить позицию    ${item}
    Log To Console    после добавления позиции
    Execute Javascript    window.scroll(1000, 1000)
    Click Element    ${loc.sumbit}
    [Return]    ${UAID}

Внести зміни в тендер
    [Arguments]    ${username}    ${tender_uaid}    ${field_name}    ${field_value}
    [Documentation]    Змінює значення поля field_name на field_value в тендері tender_uaid

Завантажити документ
    [Arguments]    ${username}    ${filepath}    ${tender_uaid}
    [Documentation]    Завантажує супроводжуючий тендерний документ в тендер tender_uaid. Тут аргумент filepath – це шлях до файлу на диску

Пошук тендера по ідентифікатору
    [Arguments]    ${username}    ${tender_uaid}
    [Documentation]    Знаходить тендер по його UAID, відкриває його сторінку

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
    [Documentation] Відповідає на запитання question з ID question_id в тендері tender_uaid відповіддю answer_data

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
    Wait Until Element Is Visible    ${locator.cabinetEnter}    10
    Click Element    ${locator.cabinetEnter}
    Wait Until Element Is Visible    ${locator.emailField}    10
    Input Text    ${locator.emailField}    ${user.login}
    Input Text    ${locator.passwordField}    ${user.password}
    Click Element    ${locator.loginButton}

Информация по закупке
    [Arguments]    ${enquiryPeriod}    ${tenderPeriod}    ${tender_data}
    #Ввод названия тендера
    ${descr}=    Get From Dictionary    ${tender_data.data}    description
    Input Text    ${locator.title}    ${descr}
    #Ввод бюджета
    ${budget}=    Get From Dictionary    ${tender_data.data.value}    amount
    ${text}=    Convert To string    ${budget}
    Input Text    ${locator.tenderBudget}    ${text}
    #Ввод мин шага
    ${min_step}=    Get From Dictionary    ${tender_data.data.minimalStep}    amount
    ${text_ms}=    Convert To string    ${min_step}
    Input Text    ${loc.MinStep}    ${text_ms}
    #Выбор НДС
    ${PDV}=    Get From Dictionary    ${tender_data.data.value}    valueAddedTaxIncluded
    Select Checkbox    ${loc.PDVIncluded}
    #Период об нач дата
    ${enquiry start}=    Get From Dictionary    ${enquiryPeriod}    startDate
    ${date_time}=    dt    ${enquiry start}
    Input Text    ${locator.enquiryPeriod.startDate}    ${date_time}
    #Период об кон дата
    ${enquiry end}=    Get From Dictionary    ${enquiryPeriod}    endDate
    ${date_time}=    dt    ${enquiry start}
    Input Text    ${locator.enquiryPeriod.endDate}    ${date_time}
    #Период приема предложений (нач дата)
    ${tender_start}=    Get From Dictionary    ${tenderPeriod}    startDate
    ${date_time}=    dt    ${tender_start}
    Input Text    ${locator.tenderStart}    ${date_time}
    #Период приема предложений (кон дата)
    ${tender_end}=    Get From Dictionary    ${tenderPeriod}    endDate
    ${date_time}=    dt    ${tender_end}
    Input Text    ${locator.tenderEnd}    ${date_time}

Информация по позиции

Добавить позицию
    [Arguments]    ${item}
    #Клик доб позицию
    Wait Until Element Is Visible    ${loc.AddPoss}
    Click Button    ${loc.AddPoss}
    Wait Until Element Is Visible    ${loc.itemDescription}
    #Название предмета закупки
    ${add_classif}=    Get From Dictionary    ${item}    additionalClassifications
    ${itemDescript}=    Get From List    ${add_classif}    0
    ${itemDescript}=    Get From Dictionary    ${itemDescript}    description
    Input Text    ${loc.editItemQuantity}    ${itemDescript}
    #Количество товара
    ${editItemQuant}=    Get From Dictionary    ${item}    quantity
    Input Text    \    ${editItemQuant}
    ${unit}=    Get From Dictionary    ${item}    unit
    ${code}=    Get From Dictionary    ${unit}    code
    Log To Console    1111111111
    Click Element    xpath=.//*[@id='window_itemadd']/div[2]/div/div[2]/div[2]/div/div[2]/div/button
    Wait Until Element Is Enabled    ${loc.input_MeasureItem}
    Select From List By Value    ${loc.MeasureItem}    KGM
    Click Button    ${loc.button_add_cpv}
    Wait Until Element Is Visible    ${loc.cpv_search}
    Input Text    ${loc.cpv_search}    2200
    Click Button    ${loc.populate_cpv}
    Wait Until Element Is Visible    xpath=.//*[@id='button_add_dkpp']
    Click Button    xpath=.//*[@id='button_add_dkpp']
    Wait Until Element Is Visible    ${loc.dkpp_search}
    Input Text    ${loc.dkpp_search}    0000
    Click Element    xpath=.//*[@id='000_NONE_anchor']
    Click Button    ${loc.populate_dkpp}
    Wait Until Element Is Enabled    ${loc.date_delivery_start}
    Log To Console    1111111
    ${delivery_Date}=    Get From Dictionary    ${item.deliveryDate}    endDate
    Log To Console    222222
    ${date_time}=    dt    ${delivery_Date}
    Log To Console    33333333
    Capture Page Screenshot
    Comment    Click Element    ${loc.date_delivery_end}
    Comment    Wait Until Element Is Visible    ${loc.AddItemButton}
    Click Button    xpath=.//*[@id='AddItemButton']

date_Time
    [Arguments]    ${date}
    ${DT}=    Convert Date    ${date}    date_format=
    Return From Keyword    '${DT.day}'+'.'+'${DT.month}'+'.'+'${DT.year}'+' '+'${DT.hour}'+':'+'${DT.minute}'
    [Return]    ${aps_date}
