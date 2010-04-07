#!/bin/bash
# simple script to barf out all spells into a file
. /etc/sorcery/config
for spell in $(codex_get_all_spells) ; do
	echo "$(basename $spell)"
done > allspells
