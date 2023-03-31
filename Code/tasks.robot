*** Settings ***
Documentation       Order robots from the RobotSpareBin Industries inc website using the csv file. 
...                 Save the order HTML receipt as a PDF.
...                 Save the screenshot of the robot.
...                 Embed the screenshot of the robot into the PDF file where the receipt is.
...                 Create a ZIP archive of all the files generated from the process.
Library    RPA.HTTP
Library    RPA.Tables
Library    RPA.Browser.Selenium
Library    RPA.PDF
Library    Collections
Library    RPA.Archive
Library    OperatingSystem


*** Tasks ***
Order robots from the RobotSpareBin Industries INC 
    Open the order website
    Get order file
    ${table}=    Convert the CSV file into a table

    FOR    ${row}    IN    @{table}
        Fill the form and preview the robot for one order    ${row}
        Wait Until Keyword Succeeds    10x    0.5s   
        ...    Order the robot
        
        Get the receipt    ${row}
    END

    Create zip file for all receipts
    Cleanup


*** Keywords ***
Get order file
    ${orders_csv}=    Download    https://robotsparebinindustries.com/orders.csv    overwrite=${True}
    Log    New orders csv file downloaded


Convert the CSV file into a table 
    ${orders_table}=    Read table from CSV    orders.csv    dialect=excel
    Log    orders.csv converted into table
    RETURN    ${orders_table}


Open the order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order


Close the annoying modal
    Click Button    OK


Fill the form and preview the robot for one order
    [Arguments]    ${order_details}

    Close the annoying modal
    Select From List By Index    head    ${order_details}[Head]
    Select Radio Button    body    id-body-${order_details}[Body]
    Input Text    class:form-control    ${order_details}[Legs]
    Input Text    address    ${order_details}[Address]
    Click Button    id:preview


Order the robot
    Click Button    id:order
    Is Element Visible    id:receipt    ${False}


Get the receipt
    [Arguments]    ${row}

 
    ${receipt_html}=    Get Element Attribute    id:receipt    outerHTML
    ${receipt_pdf}=    Html To Pdf    ${receipt_html}    pdf_receipts/${row}[Order number].pdf

    ${image}=    Capture Element Screenshot    id:robot-preview-image    robot.png 
    @{robot_images}=    Create List    ${image}

    Open Pdf    pdf_receipts/${row}[Order number].pdf
    Add files to Pdf    ${robot_images}   pdf_receipts/${row}[Order number].pdf    ${True}
    Close All Pdfs

    Log    Receipt made for order ${row}[Order number]

    Click Button    id:order-another


Create zip file for all receipts
    Archive Folder With Zip    .${/}pdf_receipts    ${OUTPUT_DIR}${/}pdf_receipts.zip
    Log    Zip archive made


Cleanup
    Remove Directory    .${/}pdf_receipts    ${True}
    Remove File    .${/}orders.csv    
    Remove File    .${/}robot.png
    Log    Cleanup done