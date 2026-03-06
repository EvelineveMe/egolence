from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page(viewport={"width":1280, "height":2000})
    page.goto("http://localhost:8000")
    page.wait_for_timeout(2000)
    page.screenshot(path="/root/.openclaw/workspace/egolence_preview.png", full_page=True)
    browser.close()
