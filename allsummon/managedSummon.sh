#!/bin/bash
# a fork of the threaded summon that will not exit until all the 
# background jobs are completed

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

# turn off immediate job notification
set +b

#trap USR1 signal with null action
trap test USR1

# set up an alarm for me
{ sleep 1; kill -USR1 $$; } &
#disown it so it doesn't show up in our job table
disown $!

# keep waiting until all jobs are complete
while ! wait; do
	DONE=`jobs -n | sed -n '/ Done / s/^\[\([0-9]*\)\].*/\1/p'`
	if [ -n "$DONE" ]; then
		echo -n "Jobs $DONE were completed at "
		date
	fi
	#restart the timer
	{ sleep 1; kill -USR1 $$ ; } &
	disown $!
done
