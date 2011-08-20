Feature: Download all files in the grimoires on the machine
  As a smgl user, I want to have a fallback mirror kept up to date as efficiently as possible
  so that I can easily keep versions of source files around

  Scenario: Downloads all spells from all grimoires
    Given "stable" grimoire is on the system
    And "test" grimoire is on the system
    When the downloader is run
    Then all spells from "stable" are downloaded
    And all spells from "test" are downloaded

  Scenario: Downloads all spells from a grimoire
    Given "stable" grimoire is on the system
    When the downloader is run
    Then all spells from "stable" are downloaded

  Scenario: Failed spells are logged
    Given "stable" grimoire is on the system
    And some spells will fail to download
    When the downloader is run
    Then the failed spells will be logged