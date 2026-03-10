*** Settings ***

Documentation           Test suite for WebShop.
Library                 QWeb
Suite Setup             Open Browser    about:blank    chrome
Suite Teardown          Close All Browsers


*** Test Cases ***

UC001: Navigates webshop and verify cart functionality
    [Documentation]     Select a product, verify details on the page,
    ...                 add the product to the cart and continue shopping.
    GoTo                https://qentinelqi.github.io/shop/
    VerifyText          Gerald the Giraffe
    ClickText           Gerald the Giraffe
    VerifyText          $9.00
    ClickText           Add to cart
    VerifyText          Cart summary
    VerifyText          Gerald the Giraffe
    VerifyText    $9.00    anchor=Total
    ClickText           Continue shopping
