#!/bin/sh

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/. */

# Install Node.js dependencies and build user scripts
npm install
npm run build

replace_dollar_all_tags () {
    awk '\
        { if ($0 ~ /\$all$/) \
            print \
            substr($0, 0, length($0) - 4)"^\$document,popup\n" \
            substr($0, 0, length($0) - 4)"^\n" \
            substr($0, 0, length($0) - 4)"^\$font\n" \
            substr($0, 0, length($0) - 4)"^\$script"; \
        else print; }' "${@:--}" $1 > ${1}_tmp1
    rm $1
    mv ${1}_tmp1 $1
}

extract_excluding_rules () {
    awk '/^@/' $1 > ${1}_safe
}

extract_valid_rules () {
    awk '/^\||^[a-zA-Z0-9]+.*##/' $1 > ${1}_tmp1
    rm $1
    mv ${1}_tmp1 $1
}

aggregate_standard_lists () {
    standard_lists=()
    while IFS= read -r line; do sanitized_filename=$(echo $line | tr -dc '[:alnum:]\n\r' | tr '[:upper:]' '[:lower:]'); standard_lists+=("$sanitized_filename"); done <../standard_lists
    for i in "${standard_lists[@]}"
    do
        replace_dollar_all_tags $i
        extract_excluding_rules $i
        extract_valid_rules $i
    done
    
    awk '{if (!standardRules[$0]++) print}' ${standard_lists[@]} > standard
    rm ${standard_lists[@]}
    
    safe_standard_lists=( "${standard_lists[@]/%/_safe}" )
    
    cat ../../content_blocker_safelist >> standard
    awk '{if (!safeStandardRules[$0]++) print}' ${safe_standard_lists[@]} >> standard
    
    rm ${safe_standard_lists[@]}
}

aggregate_strict_lists () {
    strict_lists=()
    while IFS= read -r line; do sanitized_filename=$(echo $line | tr -dc '[:alnum:]\n\r' | tr '[:upper:]' '[:lower:]'); strict_lists+=("$sanitized_filename"); done <../strict_lists
    for i in "${strict_lists[@]}"
    do
        replace_dollar_all_tags $i
        extract_excluding_rules $i
        extract_valid_rules $i
    done
    
    awk '{if (!strictRules[$0]++) print}' ${strict_lists[@]} > strict
    rm ${strict_lists[@]}
    
    safe_strict_lists=( "${strict_lists[@]/%/_safe}" )
    
    cat ../../content_blocker_safelist >> strict
    awk '{if (!safeStrictRules[$0]++) print}' ${safe_strict_lists[@]} >> strict
    
    rm ${safe_strict_lists[@]}
}

cd content-blocker-lib-ios

echo ""
echo "⤵️  Downloading lists"
curl https://f.qwant.com/tracking-protection/firefox_filters.json > lists.json

echo ""
echo "↔️  Expanding lists"
(cd TrackingProtection && swift run TrackingProtection)

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
rm lists.json
rm Lists/standard Lists/strict

echo ""
echo "✅ Done !"
