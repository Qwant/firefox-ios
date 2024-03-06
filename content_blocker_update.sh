#!/bin/sh

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/. */

# Install Node.js dependencies and build user scripts
npm install
npm run build

sort_rules () {
    awk '/^@/' $1 > ${1}_safe
    awk '!/[^a-zA-Z]qwant[^a-zA-Z]/ && !/[^a-zA-Z]qwantjunior[^a-zA-Z]/ && !/^@/' $1 > ${1}_tmp
    rm $1
    mv ${1}_tmp $1
}

aggregate_standard_lists () {
    standard_lists=()
    while IFS= read -r line; do sanitized_filename=$(echo $line | tr -dc '[:alnum:]\n\r' | tr '[:upper:]' '[:lower:]'); standard_lists+=("$sanitized_filename"); done <../QwantVIP_Lists/standard_lists
    for i in "${standard_lists[@]}"
    do
        sort_rules $i
    done
    
    awk '{if (!standardRules[$0]++) print}' ${standard_lists[@]} > standard
    rm ${standard_lists[@]}
    
    safe_standard_lists=( "${standard_lists[@]/%/_safe}" )
    
    cat ../QwantVIP_Lists/safelist >> standard
    awk '{if (!safeStandardRules[$0]++) print}' ${safe_standard_lists[@]} >> standard
    
    rm ${safe_standard_lists[@]}
}

aggregate_strict_lists () {
    strict_lists=()
    while IFS= read -r line; do sanitized_filename=$(echo $line | tr -dc '[:alnum:]\n\r' | tr '[:upper:]' '[:lower:]'); strict_lists+=("$sanitized_filename"); done <../QwantVIP_Lists/strict_lists
    for i in "${strict_lists[@]}"
    do
        sort_rules $i
    done
    
    awk '{if (!strictRules[$0]++) print}' ${strict_lists[@]} > strict
    rm ${strict_lists[@]}
    
    safe_strict_lists=( "${strict_lists[@]/%/_safe}" )
    
    cat ../QwantVIP_Lists/safelist >> strict
    awk '{if (!safeStrictRules[$0]++) print}' ${safe_strict_lists[@]} >> strict
    
    rm ${safe_strict_lists[@]}
}

cd firefox-ios/Client/ContentBlocker

echo ""
echo "↔️  Preparing lists"
(cd QwantVIP && swift run)

echo ""
echo "⤵️  Downloading list converter"
git clone https://github.com/Qwant/SafariConverterLib.git -b qwant-main

echo ""
echo "↔️  Aggregating lists"
(cd Lists && aggregate_standard_lists)
(cd Lists && aggregate_strict_lists)

echo ""
echo "🔄 Converting lists"
(cd SafariConverterLib && cat ../Lists/standard | swift run ConverterTool --safari-version 16 --optimize true --advanced-blocking true --advanced-blocking-format json --output-file-name Lists/standard)
(cd SafariConverterLib && cat ../Lists/strict | swift run ConverterTool --safari-version 16 --optimize true --advanced-blocking true --advanced-blocking-format json --output-file-name Lists/strict)

echo ""
echo "🧹 Doing some cleanup"
rm -rf SafariConverterLib
rm QwantVIP_Lists/lists.json
rm Lists/standard Lists/strict

echo ""
echo "✅ Done !"
