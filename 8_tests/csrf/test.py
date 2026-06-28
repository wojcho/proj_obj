import pytest
from selenium import webdriver
from selenium.webdriver.common.by import By
import time


BASE_URL = "http://localhost:5000"


@pytest.fixture
def driver():
    options = webdriver.ChromeOptions()
    options.add_argument("--headless=new")
    driver = webdriver.Chrome(options=options)
    yield driver
    driver.quit()


def login(driver):
    driver.get(BASE_URL + "/")

    driver.find_element(By.NAME, "username").send_keys("alice")
    driver.find_element(By.NAME, "password").send_keys("password123")
    driver.find_element(By.TAG_NAME, "button").click()

    assert "/settings" in driver.current_url


def test_csrf_vulnerability(driver):
    # login legitimate user session
    login(driver)

    # confirm initial email
    driver.get(BASE_URL + "/settings")
    original_email = driver.find_element(By.NAME, "email").get_attribute("value")

    # open malicious CSRF page (feigned attacker site)
    driver.get("http://localhost:5001/")

    # switch tabs (simulate victim browsing attacker page while logged in)
    driver.switch_to.window(driver.window_handles[-1])
    time.sleep(1)

    # go back to settings page and check if change happened
    driver.switch_to.window(driver.window_handles[0])
    driver.get(BASE_URL + "/settings")

    new_email = driver.find_element(By.NAME, "email").get_attribute("value")

    # CSRF vulnerability assertion:
    # If this passes, CSRF protection is missing
    assert new_email == "attacker@evil.com"
    assert new_email != original_email
