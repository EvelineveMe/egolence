import asyncio
from playwright.async_api import async_playwright

async def run():
    async with async_playwright() as p:
        # Launch browser in headless mode
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page()
        
        # Set a standard desktop viewport
        await page.set_viewport_size({"width": 1280, "height": 800})
        
        # Navigate to the local server
        try:
            await page.goto('http://localhost:8000', timeout=60000 )
            # Wait for the "Plum" design to load
            await page.wait_for_timeout(2000) 
            
            # Take a full-page screenshot
            await page.screenshot(path='/root/.openclaw/workspace/egolence_preview.png', full_page=True)
            print("Screenshot saved to /root/.openclaw/workspace/egolence_preview.png")
        except Exception as e:
            print(f"Error: {e}")
        finally:
            await browser.close()

if __name__ == "__main__":
    asyncio.run(run())
