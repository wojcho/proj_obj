from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

BASE_URL = "http://localhost:8080"


def create_driver():
  options = Options()
  return webdriver.Chrome(options=options)


def test_required_fields():
  driver = create_driver()

  try:
    driver.get(f"{BASE_URL}/login")

    submit_button = driver.find_element(By.CSS_SELECTOR, "button[type='submit']")
    submit_button.click()

    username = driver.find_element(By.NAME, "username")
    password = driver.find_element(By.NAME, "password")

    # Browser should not submit because fields are required
    assert username.get_attribute("validationMessage") != ""
    assert password.get_attribute("value") == ""

    # Still on login page
    assert "/login" in driver.current_url

  finally:
    driver.quit()


def test_email_must_have_valid_format():
  driver = create_driver()

  try:
    driver.get(f"{BASE_URL}/login")

    username = driver.find_element(By.NAME, "username")
    password = driver.find_element(By.NAME, "password")
    submit_button = driver.find_element(By.CSS_SELECTOR, "button[type='submit']")

    username.send_keys("not-an-email")
    password.send_keys("anything")

    submit_button.click()

    # HTML5 email validation should fail
    assert username.get_attribute("validationMessage") != ""

    # Form should not be submitted
    assert "/login" in driver.current_url

  finally:
    driver.quit()


def test_correct_login():
  driver = create_driver()

  try:
    driver.get(f"{BASE_URL}/login")

    username = driver.find_element(By.NAME, "username")
    password = driver.find_element(By.NAME, "password")
    submit_button = driver.find_element(By.CSS_SELECTOR, "button[type='submit']")

    username.send_keys("premier@gov.pl")
    password.send_keys("admin1")

    submit_button.click()

    WebDriverWait(driver, 5).until(
      lambda d: "/secret/" in d.current_url
    )

    expected_url = (
      f"{BASE_URL}/secret/premier@gov.pl?password=admin1"
    )

    assert driver.current_url == expected_url

  finally:
    driver.quit()


def test_wrong_username_and_password():
  driver = create_driver()

  try:
    driver.get(f"{BASE_URL}/login")

    username = driver.find_element(By.NAME, "username")
    password = driver.find_element(By.NAME, "password")
    submit_button = driver.find_element(By.CSS_SELECTOR, "button[type='submit']")

    username.send_keys("wrong@gov.pl")
    password.send_keys("wrongpassword")

    submit_button.click()

    WebDriverWait(driver, 5).until(
      EC.url_contains("error")
    )

    assert "/login" in driver.current_url
    assert "error" in driver.current_url

    error_box = driver.find_element(By.CLASS_NAME, "error-msg")
    assert error_box.is_displayed()

  finally:
    driver.quit()
