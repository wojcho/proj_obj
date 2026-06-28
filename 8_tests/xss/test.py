from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException

BASE_URL = "http://localhost:3000"


def create_driver():
    options = Options()
    return webdriver.Chrome(options=options)


def wait_for_dialog(driver):
    return WebDriverWait(driver, 5).until(
        EC.visibility_of_element_located((By.CSS_SELECTOR, "[role='dialog']"))
    )

def test_product_name_script_not_executed():
    driver = create_driver()

    try:
        driver.get(f"{BASE_URL}/products")

        WebDriverWait(driver, 5).until(
            EC.element_to_be_clickable((By.XPATH, "//button[contains(., 'New Product')]"))
        ).click()

        dialog = wait_for_dialog(driver)

        fields = dialog.find_elements(By.TAG_NAME, "input")

        fields[0].send_keys("<script>alert('xss')</script>")
        fields[1].send_keys("100")
        fields[2].send_keys("5")

        dialog.find_element(
            By.XPATH,
            ".//button[contains(., 'Create')]"
        ).click()

        try:
            WebDriverWait(driver, 2).until(EC.alert_is_present())
            assert False, "Stored XSS executed"
        except TimeoutException:
            pass

    finally:
        driver.quit()

def test_product_description_script_not_executed():
    driver = create_driver()

    try:
        driver.get(f"{BASE_URL}/products")

        WebDriverWait(driver, 5).until(
            EC.element_to_be_clickable((By.XPATH, "//button[contains(., 'New Product')]"))
        ).click()

        dialog = wait_for_dialog(driver)

        inputs = dialog.find_elements(By.TAG_NAME, "input")
        textarea = dialog.find_element(By.TAG_NAME, "textarea")

        inputs[0].send_keys("Normal product")
        textarea.send_keys("<script>alert(document.domain)</script>")
        inputs[1].send_keys("200")
        inputs[2].send_keys("10")

        dialog.find_element(
            By.XPATH,
            ".//button[contains(., 'Create')]"
        ).click()

        try:
            WebDriverWait(driver, 2).until(EC.alert_is_present())
            assert False, "Stored XSS executed"
        except TimeoutException:
            pass

    finally:
        driver.quit()

def test_img_onerror_not_executed():
    driver = create_driver()

    try:
        driver.get(f"{BASE_URL}/products")

        WebDriverWait(driver, 5).until(
            EC.element_to_be_clickable((By.XPATH, "//button[contains(., 'New Product')]"))
        ).click()

        dialog = wait_for_dialog(driver)

        inputs = dialog.find_elements(By.TAG_NAME, "input")
        textarea = dialog.find_element(By.TAG_NAME, "textarea")

        payload = '<img src=x onerror="alert(1)">'

        inputs[0].send_keys(payload)
        textarea.send_keys(payload)
        inputs[1].send_keys("100")
        inputs[2].send_keys("3")

        dialog.find_element(
            By.XPATH,
            ".//button[contains(., 'Create')]"
        ).click()

        try:
            WebDriverWait(driver, 2).until(EC.alert_is_present())
            assert False, "Image XSS executed"
        except TimeoutException:
            pass

    finally:
        driver.quit()
