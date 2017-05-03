*** Settings ***

*** Variables ***
${item_index}     0
${locator_create_dop_zak}    xpath=.//*[@id='header']/nav/div[4]/ul/li[1]/ul/li[1]['Допорогова закупівля']
${locator_enter}    xpath=.//*[@id='butLoginPartial']
${locator_cabinetEnter}    xpath=.//*[@id='header']/nav/div[4]/ul/li[4]/a
${locator_emailField}    id=Email    # id=Email
${locator_passwordField}    id=Password    # id=Password
${locator_loginButton}    id=submitLogin
${locator_buttonTenderAdd}    xpath=.//a[@href="/Purchase/Create"]    # додати допорогову закупівлю
${locator_tenderTitle}    id=title
${locator_button_create}    id=btn_create_purchase
${locator_budget}    id=budget
${locator_min_step}    id=min_step
${locator_pdv}    xpath=.//*[@id='is_vat']/div[1]/div[2]/div
${locator_discussionDate_start}    id=period_enquiry_start
${locator_discussionDate_end}    id=period_enquiry_end
${locator_bidDate_start}    id=period_tender_start
${locator_bidDate_end}    id=period_tender_end
${locator_button_next_step}    id=next_step
${locator_add_item_button}    xpath=.//*[@id='wrapper']/div/div/div/div[3]/div[1]/div/button
${locator_item_description}    xpath=.//*[@id='description']
${locator_Quantity}    id=Quantity
${locator_code}    id=UnitCode
${locator_button_add_cpv}    xpath=.//*[@id='updateOrCreateForm']/div[5]/div/div[1]/div/span/button
${locator_cpv_search}    id=search-classifier-text
${locator_add_classifier}    id=add-classifier
${locator_button_add_dkpp}    xpath=.//*[@id='updateOrCreateForm']/div[5]/div/div[2]/div/span/button
${locator_dkpp_search}    id=search-classifier-text
${locator_add_classfier}    id=add-classifier
${locator_date_delivery_end}    id=DeliveryEnd
${locator_button_create_item}    xpath=.//*[@id='updateOrCreateFeature']/div/div[9]/div/button[1]
${locator_check_location}    xpath=.//*[@id='IsMultilot']/div[1]/div[2]/div
${locator_country_id}    id=CountryId
${locator_SelectRegion}    id=repeatSelectRegion
${locator_postal_code}    id=ZipCode
${locator_locality}    id=Locality
${locator_street}    id=Street
${locator_search}    id=Search
${locator_search-btn}    id=search-btn
${locator_currency}    xpath=.//*[@id='wrapper']/div[2]/div/div/div/div/div/div/div/form/div[6]/div/select
