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
Resource          Angular.robot
Resource          aps.keywords.robot

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
    Comment    Log To Console
    Set Window Size    @{user.size}
    Run Keyword If    '${role}'!='aps_Viewer'    Login    ${user}
    Comment    Run Keyword If    '${role}'='aps_Viewer'    ${user}

aps.Адаптувати дані для оголошення тендера
    [Arguments]    ${username}    ${tender_data}
    [Documentation]    Змінює деякі поля в tender_data (автоматично згенерованих даних для оголошення тендера) згідно з особливостями майданчика
    [Return]    ${y}

aps.Створити тендер
    [Arguments]    ${g}    ${tender_data}
    [Documentation]    Створює однопредметний тендер
    Log To Console    ${SUITE_NAME}
    Comment    Wait Until Element Is Visible    ${locator_button_create}    5
    Comment    Click Element    ${locator_button_create}
    Run Keyword If    '${SUITE_NAME}'=='Tests Files.singleItemTender'    Допороговый однопредметный тендер    ${tender_data}
    Run Keyword If    ${SUITE_NAME}'=='Tests Files.openEU.robot    Открытые торги с публикацией на англ    ${tender_data}
    Run Keyword If    ${SUITE_NAME}'=='Tests Files.openUA.robot    Открытые торги с публикацией на укр    ${tender_data}
    Run Keyword If    ${SUITE_NAME}'=='Tests Files.negotiation.robot    Переговорная мультилотовая процедура    ${tender_data}
    Run Keyword If    ${SUITE_NAME}'=='Tests Files.singleItemTenderComplaints.robot    Работа с жалобами    ${tender_data}
    [Return]    ${UAID}

aps.Внести зміни в тендер
    [Arguments]    ${username}    ${tender_uaid}    ${field_name}    ${field_value}
    [Documentation]    Змінює значення поля field_name на field_value в тендері tender_uaid
    aps.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
    Wait Until Element Is Enabled    ${loc_TenderPublishTop}
    Click Element    ${loc_TenderPublishTop}

Завантажити документ
    [Arguments]    ${username}    ${filepath}    ${tender_uaid}
    [Documentation]    Завантажує супроводжуючий тендерний документ в тендер tender_uaid. Тут аргумент filepath – це шлях до файлу на диску
    Поиск тендера по идентификатору    ${username}    ${tender_uaid}

aps.Пошук тендера по ідентифікатору
    [Arguments]    ${username}    ${tender_uaid}
    [Documentation]    Знаходить тендер по його UAID, відкриває його сторінку
    Поиск тендера по идентификатору    ${username}    ${tender_uaid}

Оновити сторінку з тендером
    [Arguments]    ${username}    ${tender_uaid}
    [Documentation]    Оновлює інформацію на сторінці, якщо відкрита сторінка з тендером, інакше переходить на сторінку з тендером tender_uaid
    Reload Page

Отримати інформацію із тендера
    [Arguments]    ${username}    ${field_name}
    [Documentation]    Return значення поля field_name, яке бачить користувач username
    [Return]    field_value

Задати питання
    [Arguments]    ${username}    ${tender_uaid}    ${question}
    [Documentation]    Задає питання question від імені користувача username в тендері tender_uaid

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
