#!/bin/bash
. /etc/sorcery/config
# cleanup
echo "Preparing environment"
mkdir -p splits
cd splits
rm all*

echo -n "Acquiring spells ..."
for spell in $(codex_get_all_spells) ; do
	echo "$(basename $spell)"
done > allspells
echo "done."

COUNT="$(wc -l allspells | cut -f 1 -d" ")"
THREADS=3

SPLIT_SIZE=$(( $COUNT/4 ))

echo "Starting up $THREADS summon threads..."
echo -n "Splitting up into ${SPLIT_SIZE} spell chunks..."
split  -l ${SPLIT_SIZE} allspells all-
echo "done."

echo "Starting summonses"
for foo in `ls all-*`; do
	summon `cat $foo` 2>&1 > $foo-summonLog &
done
