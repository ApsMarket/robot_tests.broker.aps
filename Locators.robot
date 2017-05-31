*** Settings ***

*** Variables ***
${item_index}     0
${locator_create_dop_zak}    xpath=.//a[@id='url_create_purchase_0']
${locator_enter}    xpath=.//*[@id='butLoginPartial']
${locator_cabinetEnter}    xpath=.//*[@id='header']/nav/div[2]/ul/li[4]/a
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
${locator_button_next_step}    xpath=.//*[@id='next_step']
${locator_add_item_button}    id=add_procurement_subject0
${locator_item_description}    id=procurementSubject_description00
${locator_Quantity}    id=procurementSubject_quantity00
${locator_code}    id=select_unit00
${locator_button_add_cpv}    id=cls_click_00
${locator_cpv_search}    id=search-classifier-text
${locator_button_add_dkpp}    xpath=.//*[@id='updateOrCreateProcurementSubject_0_0']/div[2]/div[4]/div/div[2]/div/span/button
${locator_dkpp_search}    id=search-classifier-text
${locator_add_classfier}    id=add-classifier
${locator_date_delivery_end}    id=delivery_end_
${locator_button_create_item}    id=update_00
${locator_check_location}    xpath=.//*[@id='is_delivary_00']/div[1]/div[2]/div
${locator_country_id}    xpath=.//*[@id='select_countries00']['Україна']
${locator_SelectRegion}    id=select_regions00
${locator_postal_code}    id=zip_code_00
${locator_locality}    id=locality_00
${locator_street}    id=street_00
${locator_search}    id=Search
${locator_search-btn}    id=search-btn
${locator_currency}    xpath=.//select[@ng-model="purchase.currency"]
${locator_items}    xpath=.//*[@id='procurementSubjectTab']/a
${locator_deliveryLocation_latitude}    id=latutide_00
${locator_deliveryLocation_longitude}    id=longitude_00
${locator_check_dk}    xpath=.//*[@id='tree']
${next_step}      id=next_step
${locator_documents}    xpath=.//*[@id='documentsTab']/a[contains(@href,"#documents")]    # .//*[@id='documentsTab']/a[@href='#documents']
${locator_add_ documents}    xpath=.//*[@id='documents']/div/div/div[1]/div/div
${locator_category}    xpath=.//*[@id='documents']/div/div/div[2]/div/div[1]/div[1]/div/div[1]/select
${locator_add_documents_to}    xpath=.//*[@id='documents']/div/div/div[2]/div/div[1]/div[1]/div/div[2]/select
${locator_download}    xpath=.//*[@id='documents']/div/div/div[2]/div/div[1]/div[2]/div/span/label[@class='btn btn-primary']
${locator_input_download}    xpath=.//*[@id='documents']/div/div/div[2]/div/div[1]/div[2]/div/span/label[@class='btn btn-primary']
${locator_save_document}    xpath=.//*[@id='documents']/div/div/div[2]/div/div[2]/button[1]    # кнопка "Зберегти"
${locator_next_step}    id=next_step
${locator_finish_edit}    id=movePurchaseView    # завешити редагування
${locator_publish_tender}    id=publishPurchase    # публікація тендеру
${locator_toast_container}    id=toast-container
${locator_toast_close}    xpath=.//*[@class='toast-close-button']
