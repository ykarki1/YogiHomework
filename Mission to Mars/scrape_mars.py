# importing modules
import os
import pandas as pd
from bs4 import BeautifulSoup as bs
from splinter import Browser
import requests
import time

def init_browser():
    executable_path = {"executable_path": "/usr/local/bin/chromedriver"}
    return Browser("chrome", **executable_path, headless=False)

#creating a function to create a soup object by taking in the URL
def make_soup(url):
    """ Requests module retrives the web page and BeautifulSoup converts it into the soup object"""
    response = requests.get(url)
    soup = bs(response.text, "html.parser")
    return soup

#scraping of all required data
def scrape():
    browser = init_browser()
    mars_data = {}

    #Mars News site: "https://mars.nasa.gov/news/"
    soup1 = make_soup("https://mars.nasa.gov/news/")

    #selected the required element out of the page by inspecting the actual element
    result1 = soup1.find('div', class_= "slide")

    #required texts
    mars_data["news_title"] = (result1.find_all("a"))[1].text.strip()
    mars_data["news_p"] = (result1.find_all("a"))[0].text.strip()


    # scraping the featured image from www.jpl.nasa.gov
    #Featured image url to be extracted from "https://www.jpl.nasa.gov/spaceimages/?search=&category=Mars"
    jpl_url = "https://www.jpl.nasa.gov/spaceimages/?search=&category=Mars"
    #visiting the browser
    browser.visit(jpl_url)
    time.sleep(2)
    #Click on the full image button
    browser.click_link_by_partial_text('FULL IMAGE')
    time.sleep(2)

    # HTML object
    html = browser.html
    # Parse HTML with Beautiful Soup
    soup = bs(html, 'html.parser')
    #quit the open browser
    browser.quit()

    featureimg = soup.find("div", class_="carousel_items").find("article", class_="carousel_item")["style"]
    #stripping off unnecessary characters from the scraped object
    jplimgurl = featureimg.strip("background-image: url();").strip("''")
    #since the above url didn't come with main domain, we're going to concatenate it with the main domain
    main_domain ="https://www.jpl.nasa.gov"

    mars_data["feature_img_url"] = main_domain+jplimgurl

    ### scraping the mars weather from its twitter account
    #Extracting Mars weather from its twitter account "https://twitter.com/marswxreport?lang=en"
    soup3 = make_soup("https://twitter.com/marswxreport?lang=en")
    latest_weather = soup3.find("p",class_="TweetTextSize TweetTextSize--normal js-tweet-text tweet-text")
    mars_data["mars_weather"] = latest_weather.text[:-26] #removing last 26 characters which had picture url

    #Mars facts scraping from "http://space-facts.com/mars/"
    fact_table = pd.read_html("https://space-facts.com/mars/")
    mars_fact = fact_table[0]
    mars_fact.columns = ["Attribute","Value"]
    mars_fact.set_index(["Attribute"],inplace=True)
    mars_data["mars_table_html"]=mars_fact.to_html()


    ### scraping the hemisphere images from astrogeology.usgs.gov
    #Hemisphere images from "https://astrogeology.usgs.gov/search/results?q=hemisphere+enhanced&k1=target&v1=Mars"
    soup4 = make_soup("https://astrogeology.usgs.gov/search/results?q=hemisphere+enhanced&k1=target&v1=Mars")
    
    #list of hemispheres names
    hemispheres= soup4.find_all("h3")
    #extracting text string of the hemisphere's names
    hemisphere_list =[x.text for x in hemispheres]

    #Empty list for image urls
    image_urls = []

    #looping through the hemisphere list to click on the link with the text of each hemisphere name
    for hemi_name in hemisphere_list:
        hemi_url = "https://astrogeology.usgs.gov/search/results?q=hemisphere+enhanced&k1=target&v1=Mars"
        browser.visit(hemi_url)
        time.sleep(2)
        browser.click_link_by_partial_text(hemi_name)
        html = browser.html
        time.sleep(1)
        soup = bs(html, 'html.parser')
        img_url =soup.find('a', target= "_blank")["href"]
        #quitting the browser to open another link from the main page in next loop
        browser.quit()
        
        #creating dictionary of title and image url
        url_dict = {"title": hemi_name, "img_url": img_url}
        image_urls.append(url_dict)

    mars_data["hemisphere_urls"] = image_urls

    return mars_data