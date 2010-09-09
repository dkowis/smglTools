Feature: User updates local mirror
	As a user, I want to verify the sources in my /var/spool/sorcery
	And I want to download missing sources
	So that my local mirror is complete
	And correct

	Scenario: no files are downloaded
		Given a grimoire output in yaml
		And all files are already in the spool directory
		When the downloader is run
		Then nothing should be downloaded

	Scenario: bad files are redownloaded
		Given a grimoire output in yaml
		And all files are already in the spool directory
		But some files are invalid
		When the downloader is run
		Then the bad files will be downloaded
		And the files will be verified

	Scenario: missing files are redownloaded
		Given a grimoire output in yaml
		And no files are in the spool directory
		When the downloader is run
		Then the missing files will be downloaded
		And the files will be verified
