-- Queries

-- gaze where spell
select grimoires.name as grimoire, sections.name as section
	from grimoires, sections, spells
	where spells.name = 'spell'
		and spells.section_id = sections.id
		and sections.grimoire_id = grimoire.id

-- gaze what spell <- use default grimoire of test
select spells.short as short
	from spells, grimoires, sections
	where spells.name = 'spell'
		and grimoire.name = 'test'
		and spells.section_id = sections.id
		and sections.grimoire_id = grimoires.id

-- gaze source_urls spell <- have to pick a grimoire
-- will have to pick one or NOTICE them or something
select source_urls.url as url
	from source_urls, spell_sources, spells, sections, grimoires
	where spells.name = 'spell'
		and source_urls.source_id = spell_sources.id
		and spell_sources.spell_id = spells.id
		and spells.section_id = sections.id
		and sections.grimoire_id = grimoires.id
		and grimoires.name = 'test'

-- gaze sources <-- pick a grimoire
select spell_sources.source as source, spell_sources.hash as hash
	from spell_sources, spells, sections, grimoires
	where spells.name = 'spell'
		and spell_sources.spell_id = spells.id
		and spells.section_id = sections.id
		and sections.grimoire_id = grimoires.id
		and grimoires.name = 'test'

-- gaze website <-- grimoire picking , although not as important
select spells.website as website
	from spells, sections, grimoires
	where spells.name = 'spell'
		and spells.section_id = sections.id
		and sections.grimoire_id = grimoire.id
		and grimoire = 'test'

-- gaze versions
select spells.version as version, grimoires.name as grimoire
	from spells, sections, grimoires
	where spells.name = 'spell'
		and spells.section_id = sections.id
		and sections.grimoire_id = grimoires.id

-- gaze license <-- pick a grimoire
select spells.license as license 
	from spells, sections, grimoires
	where spells.name = 'spell'
		and spells.section_id = sections.id
		and sections.grimoire_id = grimoires.id
		and grimoires.name = 'test'

-- gaze description or long
select "spells.long" as "long" 
	from spells, sections, grimoires
	where spells.name = 'spell'
		and spells.section_id = sections.id
		and sections.grimoire_id = grimoires.id
		and grimoires.name = 'test'


