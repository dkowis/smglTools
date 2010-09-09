Given /^a grimoire output in yaml$/ do
	# assume the grimoire output exists already and that's okay.
	# TODO: figure out how to ensure the yaml output exists, probably via a fixture or somethign simulated
	@test_path = File.expand_path("../../../test", __FILE__)
	@grimoire_yaml = File.new(File.join(@test_path,"/sample.yaml"))

end

Given /^all files are already in the spool directory$/ do
	#TODO: how do I put the files in here already? I should be using mocks, yes?
  pending # express the regexp above with the code you wish you had
end

When /^the downloader is run$/ do
	MirrorMaker::Downloader.new.start @grimoire_yaml
end

Then /^nothing should be downloaded$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^some files are invalid$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^the bad files will be downloaded$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^the files will be verified$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^no files are in the spool directory$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^the missing files will be downloaded$/ do
  pending # express the regexp above with the code you wish you had
end

