from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

BASE_URL = "http://localhost:3000"


def create_driver():
    return webdriver.Chrome(options=Options())


def go_home(driver):
    WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.CSS_SELECTOR, "header"))
    )

    el = WebDriverWait(driver, 10).until(
        EC.element_to_be_clickable((By.XPATH, "//a[contains(@href, '/')] | //button[contains(., 'Home')]"))
    )
    el.click()


def go_products(driver):
    WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.CSS_SELECTOR, "header"))
    )

    el = WebDriverWait(driver, 10).until(
        EC.element_to_be_clickable((By.XPATH, "//a[contains(., 'Products')]"))
    )
    el.click()


def go_users(driver):
    WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.CSS_SELECTOR, "header"))
    )

    el = WebDriverWait(driver, 10).until(
        EC.element_to_be_clickable((By.XPATH, "//a[contains(., 'Log in')]"))
    )
    el.click()


def go_user_basket(driver):
    WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.CSS_SELECTOR, "header"))
    )

    el = WebDriverWait(driver, 10).until(
        EC.element_to_be_clickable((By.XPATH, "//a[contains(., 'Basket')]"))
    )
    el.click()

def open_user_basket(driver):
    go_user_basket(driver)

    WebDriverWait(driver, 5).until(
        lambda d: (
            d.find_elements(By.TAG_NAME, "table")
            or d.find_elements(By.XPATH, "//*[contains(text(),'No items.')]")
        )
    )


def refresh_basket(driver):
    driver.find_element(
        By.XPATH,
        "//button[contains(., 'Refresh')]"
    ).click()

    WebDriverWait(driver, 5).until(
        EC.presence_of_element_located((By.TAG_NAME, "table"))
    )


def basket_rows(driver):
    rows = driver.find_elements(By.CSS_SELECTOR, "tbody tr")

    result = []

    for row in rows:
        cells = row.find_elements(By.TAG_NAME, "td")
        result.append(
            (
                cells[0].text,  # id
                cells[1].text,  # name
                cells[4].text,  # quantity
            )
        )

    return result


def remove_first_item(driver):
    delete_buttons = driver.find_elements(
        By.XPATH,
        "//button[@aria-label='Remove']"
    )

    delete_buttons[0].click()

TEST_PRODUCTS = [
    ("TEST-CONSISTENCY-1", "Created by Selenium", "100", "10"),
    ("TEST-CONSISTENCY-2", "Created by Selenium", "200", "10"),
    ("TEST-CONSISTENCY-3", "Created by Selenium", "300", "10"),
]

def wait_for_products_page(driver):
    WebDriverWait(driver, 5).until(
        EC.presence_of_element_located((By.TAG_NAME, "table"))
    )

def wait_for_basket_page(driver):
    WebDriverWait(driver, 5).until(
        lambda d: (
            d.find_elements(By.TAG_NAME, "table")
            or d.find_elements(By.XPATH, "//*[contains(text(),'No items.')]")
        )
    )

def create_product(driver, name, description, price, stock):
    driver.find_element(
        By.XPATH,
        "//button[contains(., 'New Product')]"
    ).click()

    dialog = WebDriverWait(driver, 5).until(
        EC.visibility_of_element_located((By.CSS_SELECTOR, "[role='dialog']"))
    )

    inputs = dialog.find_elements(By.TAG_NAME, "input")
    textarea = dialog.find_element(By.TAG_NAME, "textarea")

    inputs[0].send_keys(name)
    textarea.send_keys(description)
    inputs[1].send_keys(price)
    inputs[2].send_keys(stock)

    dialog.find_element(
        By.XPATH,
        ".//button[contains(., 'Create')]"
    ).click()

    WebDriverWait(driver, 5).until(
        EC.invisibility_of_element(dialog)
    )

def ensure_product(driver, name, description, price, stock):
    go_products(driver)
    wait_for_products_page(driver)

    if driver.find_elements(
        By.XPATH,
        f"//tbody//tr/td[normalize-space()='{name}']"
    ):
        return

    create_product(driver, name, description, price, stock)

def add_product_to_basket(driver, product_name):
    go_products(driver)

    WebDriverWait(driver, 5).until(
        EC.presence_of_element_located((By.TAG_NAME, "table"))
    )

    row = driver.find_element(
        By.XPATH,
        f"//tbody/tr[td[normalize-space()='{product_name}']]"
    )

    button = row.find_element(
        By.XPATH,
        ".//button[.//*[local-name()='svg']]"
    )

    WebDriverWait(driver, 5).until(
        EC.element_to_be_clickable((By.XPATH, ".//button[.//*[local-name()='svg']]"))
    )

    driver.execute_script("arguments[0].click();", button)

def clear_basket(driver):
    go_user_basket(driver)

    WebDriverWait(driver, 5).until(
        lambda d: (
            d.find_elements(By.TAG_NAME, "table")
            or d.find_elements(By.XPATH, "//*[contains(text(),'No items.')]")
        )
    )

    buttons = driver.find_elements(By.XPATH, "//tbody//button")

    while buttons:
        driver.execute_script("arguments[0].click();", buttons[0])

        WebDriverWait(driver, 5).until(
            lambda d: len(d.find_elements(By.XPATH, "//tbody//button")) < len(buttons)
        )

        buttons = driver.find_elements(By.XPATH, "//tbody//button")

def prepare_basket(driver):
    clear_basket(driver)

    for product in TEST_PRODUCTS:
        ensure_product(driver, *product)

    for name, *_ in TEST_PRODUCTS:
        add_product_to_basket(driver, name)

    open_user_basket(driver)
    wait_for_basket_page(driver)

def login_as_user(driver):
    go_users(driver)

    select = WebDriverWait(driver, 5).until(
        EC.element_to_be_clickable(
            (By.XPATH, "//div[@role='combobox' or contains(@class,'MuiSelect-select')]")
        )
    )
    select.click()

    target = WebDriverWait(driver, 5).until(
        EC.element_to_be_clickable(
            (By.XPATH, "//li[@role='option' and @data-value='bob@example.com']")
        )
    )
    target.click()

    password = driver.find_element(By.XPATH, "//input[@type='password']")
    password.send_keys("d64d1dd3-14dc-4fbf-9abf-7bf1faa3ebd9")

    driver.find_element(
        By.XPATH,
        "//button[contains(., 'Sign in')]"
    ).click()

    WebDriverWait(driver, 5).until(
        EC.url_contains("/users/")
    )




def test_refresh_synchronizes_two_tabs():
    driver = create_driver()
    try:
        driver.get(f"{BASE_URL}")
        login_as_user(driver)
        prepare_basket(driver)
        open_user_basket(driver)
        original = basket_rows(driver)

        driver.switch_to.new_window("tab")
        driver.get(f"{BASE_URL}")
        login_as_user(driver)
        open_user_basket(driver)
        remove_first_item(driver)
        modified = basket_rows(driver)

        driver.switch_to.window(driver.window_handles[0])
        stale = basket_rows(driver)
        assert stale == original
        refresh_basket(driver)
        refreshed = basket_rows(driver)
        assert refreshed == modified
    finally:
        driver.quit()
