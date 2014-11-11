#!/bin/bash

# just a stupidly simple shell script that can respond with a couple things when asked

while true; do
    read spellpath

    if [[ "$spellpath" == "stop" ]]; then
        exit 0
    fi

    if [[ "$spellpath" == "test1" ]]; then
        read -r -d '' OUTPUT <<'EOF'
{"spellPath":"/var/lib/sorcery/codex/stable/crypto/gnupg","version":"1.4.12","sourceFiles":[{"fileName":"gnupg-1.4.12.tar.bz2","hash":"GnuPG.gpg:gnupg-1.4.12.tar.bz2.sig:VERIFIED_UPSTREAM_KEY","urls":["ftp://ftp.gnupg.org/gcrypt/gnupg/gnupg-1.4.12.tar.bz2","ftp://ftp.planetmirror.com/pub/gnupg/gnupg/gnupg-1.4.12.tar.bz2","ftp://sunsite.dk/pub/security/gcrypt/gnupg/gnupg-1.4.12.tar.bz2","ftp://ftp.franken.de/pub/crypt/mirror/ftp.gnupg.org/gcrypt/gnupg/gnupg-1.4.12.tar.bz2","ftp://ftp.linux.it/pub/mirrors/gnupg/gnupg/gnupg-1.4.12.tar.bz2"]},{"fileName":"gnupg-1.4.12.tar.bz2.sig","hash":"signature","urls":["ftp://ftp.gnupg.org/gcrypt/gnupg/gnupg-1.4.12.tar.bz2.sig"]}]}
EOF
        echo "${OUTPUT}"
    elif [[ "$spellpath" == "test2" ]]; then
        read -r -d '' OUTPUT <<'EOF'
{ "spellPath": "/var/lib/sorcery/codex/stable/mail/cone", "version": "0.84",  "sourceFiles": [ { "fileName": "cone-0.84.tar.bz2", "hash": "courier.gpg:cone-0.84.tar.bz2.sig:UPSTREAM_KEY", "urls": ["http://internap.dl.sourceforge.net/sourceforge/courier/cone-0.84.tar.bz2"]}, { "fileName": "cone-0.84.tar.bz2.sig", "hash": "signature", "urls": ["http://internap.dl.sourceforge.net/sourceforge/courier/cone-0.84.tar.bz2.sig"]} ]}
EOF
        echo "${OUTPUT}"
    elif [[ "$spellpath" == "test3" ]]; then
        read -r -d '' OUTPUT <<'EOF'
{ "spellPath": "/var/lib/sorcery/codex/stable/mail/putmail", "version": "1.4",  "sourceFiles": [ { "fileName": "putmail.py-1.4.tar.bz2", "hash": "sha512:7f58ba107e9513f268f01f7d4d8bd6013b72190ef648225bed12631195a9d82b2fb7ff11142ca6df358f55bda1e64b7c2e3e76dcdfa318d07035b5024cc0f8a4", "urls": ["http://internap.dl.sourceforge.net/sourceforge/putmail/putmail.py-1.4.tar.bz2"]} ]}
EOF
        echo "${OUTPUT}"
    else
        echo "{ \"failure\": \"no such spell directory: ${spellpath}\" }"
    fi
done