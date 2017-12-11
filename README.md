# itms-scripts
Scripts to help with uploading localized app store descriptions, in app purchases, achievements, and leaderboards metadata to the App Store via the iTMSTransporter tool

The purpose of creating our own scripts is **mainly for uploading localized IAP and Game Center metadata** to the App Store in bulk, as we haven't found any other scripts that will do that.
The alternative would be to click your way through itunesconnect.apple.com to fill out a ton of information.
If you're looking to just upload screenshots and App Store metadata, we recommend checking out [deliver](https://github.com/fastlane/fastlane/tree/master/deliver).

## Features
* Upload localized screenshots
* Upload localized App Store descriptions, keywords, and other metadata
* Upload localized In-App Purchases
* Upload localized Game Center Achievements
* Upload localized Game Center Leaderboards

## Usage
Setup your `itms.config` file for your app. See the [Config](#config) section below for all the options.

Setup your metadata files. See the [Metadata](#metadata) section below for more information.

Once you have your setup complete, open terminal and run:
```
./itms.rb
```
**Options:**

`-c config_filename` - specify a different config filename

`--skip-download` - skips the itms package download (use this if you already have an .itmsp package you're working with)

`--only-download` - only downloads the itms package (does not replace contents or upload)

## Config
`username`,`password` - Your iTunes Connect account username and password (don't commit that). Note: You can remove these entries and set the ITMS\_USERNAME and ITMS\_PASSWORD environment variables instead.

`app_id` - The id for the app you want to update.
This can be found in iTunes Connect by navigating to your app, go to the App Information tab, then look under the General Information section for Apple ID.

`version` - The version of your app you're making updates to.
This only affects the app store metadata and screenshots, not IAP or Game Center.

`app_store_image_base_names` - An array of strings describing how you want to name your app store images, starting with iPhone 4 (3.5") and increasing in size to iPad Pro.
See the [App Store Images](#app-store-images) section below for more information.

`upload_app_store_screenshots` - Set to false if you don't want to upload screenshots.

`generate_xyz` options - Toggles for what you want to upload.

`verify` - Verifies your package before uploading. This happens during upload anyways so it should just be used as a dry run.

`upload_after_verify` - Uploads your package after verifying (or immediately if `verify` is false).

`clean_after_submit` - Removes the itms package after successfully submitting it.

By default, `upload_after_verify` is set to `false` since you should do a dry run first to ensure all your data looks right.

## App Store Images
Use the following convention to name your app store images that you want to upload:

`<locale>_<base_image_name>_<index>.png`

For example:

If your `app_store_image_base_names` is something like `["3.5", "4", "4.7", "5.5", "iPad", "iPadPro"]`,
your first slot images for the German language should be named:

```
de-DE_3.5_00.png
de-DE_4_00.png
de-DE_4.7_00.png
de-DE_5.5_00.png
de-DE_iPad_00.png
de-DE_iPadPro_00.png
```
Place these images in the locale subdirectory in the `app_store` directory (i.e. `app_store/de-DE`)

IAP, Achievement, and Leaderboard images should be placed in their respective subdirectories.

## Metadata
The way we provide the information to be uploaded comes in the form of `.csv` and `.tsv` files.
There are some stubbed examples in the subdirectories for each category we can provide information for.
The given filenames cannot be changed as of now, they are as follows:

`app_store/app_store_locales.tsv` - Provides the App title, keywords, software url, privacy url, and support url.

`app_store/de-DE/app_store_description.txt` - Provides the App Store description in the given locale (de-DE in this case.)

`iap/iap_metadata.csv` - Provides the id, reference name, type, cleared for sale, price tier, and image name for each in-app purchase.

`iap/iap_locales.csv` - Provides the title and description for each in-app purchase for each locale.

`achievements/achievements_metadata.csv` - Provides the id, reference name, points, and hidden for each achievement.

`achievements/achievements_locales.csv` - Provides the title, before description, after description, and image name for each achievement for each locale.

`leaderboards/leaderboards_metadata.csv` - Provides the id, reference name, and sort order for each leaderboard.

`leaderboards/leaderboards_locales.csv` - Provides the title, formatter type, and image name for each leaderboard for each locale.

Here's a Google Sheets template with all the csv/tsv templates: [iTMS Metadata Template](https://docs.google.com/spreadsheets/d/1kFDrGsMZQzgTpbhx9E1ebliKce4fAjl6TSuHdXlrZso/edit?usp=sharing)

## Caveats
### App Version
Make sure your app version exists in itunesconnect.apple.com before uploading any App Store screenshots or metadata.

### Language Support
While working with these scripts, it was apparent that some languages would not work with the iTMSTransporter. Here's a list of the languages we've tried and if they worked:

**Known Supported Languages**

de-DE, en, es, fr, it, ja, ko, ms, nl-NL, pt-BR, pt-PT, ru, th

**Known Unsupported Languages**

cs, zh-Hans, zh-Hant

### Leaderboards
If you're submitting leaderboards, the iTMSTransporter tool does not support using leaderboard sets yet, so you'll be limited to 100 leaderboards.

### iTunes Connect
It takes a little while for iTunes Connect to update with the information uploaded through the iTMSTransporter tool depending on the type of information you're uploading. App descriptions can take up to 5 minutes, achievements and leaderboards could take longer. After you run the script, just give it some time before checking iTunes Connect to ensure all the data is there.

# Need Help?

Please submit an issue on GitHub and provide information about your setup

# Contributing

This project adheres to the [Open Code of Conduct][code-of-conduct]. By participating, you are expected to honor this code.
[code-of-conduct]: http://todogroup.org/opencodeofconduct/#GitHub%20Markup/opensource@github.com

## Submitting a Pull Request

1. Fork it.
2. Create a branch (`git checkout -b my_branch`)
3. Commit your changes (`git commit -am "Made xyz a lot better"`)
4. Push to the branch (`git push origin my_branch`)
5. Open a [Pull Request](http://github.com/github/markup/pulls)
6. Go play King Rabbit while you wait :)
