#!/bin/bash

# a stupid "always running" shell script to be used from an Akka Actor (or something else) to ask for some
# spell information.
# It will return the spell information in a JSON datastructure that can be marshalled or whatever


if ! [ -f /etc/sorcery/config ]; then
    exit 255
fi

. /etc/sorcery/config


function my_get_spell_source_urls() {
    local foo
    local urlvar="SOURCE${1}_URL[*]"

    for foo in ${!urlvar}; do
        echo $foo
    done
}

function my_get_spell_source_hash() {
    local sourcevar=SOURCE${1}
    local hashvar="${sourcevar}_HASH"
    local ignorevar="${sourcevar}_IGNORE"

    if [[ "${!hashvar}" == "" ]]; then
        # no hash
        if [[ "${!ignorevar}" == "signature" ]]; then
            echo -n "${!ignorevar}"
        else
            local gpgvar="${sourcevar}_GPG"
            if [[ "${!gpgvar}" == "" ]] ; then
                # not a gpg either, must be MD5 or no hash!
                local md5var="MD5[*]"
                if [[ "${!md5var[$1]}" == "" ]]; then
                    # no verification provided!
                    echo -n "none"
                else
                    #going to break the rules here and add md5: to it
                    echo -n "md5:${!md5var[$1]}"
                fi
            else
                echo -n ${!gpgvar}
            fi
        fi
	else
		echo -n ${!hashvar}
	fi
}

function spell_json() {
        # Set the current spell info, so I have magic information I can do stuff with!
        codex_set_current_spell $1

        local source_var
        local source_url

        local source_files="{"
        # get all the sources and stick them into an array
        for source_var in $(get_source_nums SOURCE) ; do
            local source_num="${source_var##SOURCE}"
            source_var="SOURCE${source_num}"
            if [[ "${!source_var}" != "" ]]; then
                # create a source entry and start an array for the urls
                source_files="${source_files} \"${!source_var}\":{"
                # output the source hash for this source
                source_files="${source_files} \"hash\": \"$(my_get_spell_source_hash ${source_num})\","
                #In here, get each source url for this source
                source_files="${source_files} \"urls\": ["
                for source_url in $(my_get_spell_source_urls ${source_num}); do
                    # Add an entry in the array for each url
                    source_files="${source_files}\"${source_url}\","
                done
                # take off the dangling comma
                source_files="${source_files%?}"
                # close this array
                source_files="${source_files}]"
                # close the object
                source_files="${source_files}},"
            fi
        done
        # take off the dangling source files comma
        source_files="${source_files%?}"

        # close the source files object
        source_files="${source_files} }"

        read -r -d '' OUTPUT <<EOF
{ "version": "${VERSION}",  "source_files": ${source_files}}
EOF

        echo ${OUTPUT}

        codex_clear_current_spell
}

while true; do
    read spellpath

    # give ourselves a way out
    if [[ "$spellpath" == "stop" ]]; then
        exit 0
    fi

    if ! [ -d $spellpath ] ; then
        #TODO: return some structure of failure! probably JSON
        echo "{ \"failure\": \"no such spell directory: ${spellpath}\" }"
    else
        #PARSE TEH SPELL INFO
        # have to throw it into a safety shell so that it doesn't leak
        ( spell_json $spellpath )
    fi
done