//! Requires chromedriver running on port 4444:
//!
//!     chromedriver --port=4444
//!
//!     or
//!
//!     arion-up
//!

use std::{thread, time::Duration};
use thirtyfour::{prelude::*, query::*};

#[tokio::main]
async fn main() -> WebDriverResult<()> {
    let mut caps = DesiredCapabilities::chrome();
    caps.add_chrome_option(
        "prefs",
        serde_json::json!({
            "intl.accept_languages": "en,en_US"
        }),
    )?;

    let driver = WebDriver::new("http://localhost:4444", caps).await?;
    let poller =
        ElementPoller::TimeoutWithInterval(Duration::new(10, 0), Duration::from_millis(500));
    driver.set_query_poller(poller);
    // Navigate to twitter
    driver.get("https://twitter.com/i/flow/login").await?;
    thread::sleep(Duration::from_millis(4000));
    // Find element.
    let username = driver
        .find_element(By::Css("input[autocomplete='username']"))
        .await?;
    username.send_keys("agalquerque@protonmail.com").await?;
    let username_button = driver
        .find_element(By::XPath("//div[@role='button' and contains(.,'Next')]"))
        .await?;
    username_button.click().await?;
    thread::sleep(Duration::from_millis(1000));
    let username = driver
        .find_element(By::Css("input[autocomplete='current-password']"))
        .await?;
    username.send_keys("}[7`(#%HzT[FE9#|q9:q)Tps_M").await?;
    let username_button = driver
        .find_element(By::XPath("//div[@role='button' and contains(.,'Log in')]"))
        .await?;
    username_button.click().await?; // let username = driver
                                    //     .find_element(By::Name("session[username_or_email]"))
                                    //     .await?;

    // Find element from element.
    // let password = driver.find_element(By::Tag("input")).await?;

    // Type in the search terms.

    // password.send_keys("selenium").await?;

    // Always explicitly close the browser. There are no async destructors.
    //driver.quit().await?;
}
