#!/bin/bash

src_img="$1"
dst_img="$2"

function get_branch_name()
{
  local env_branch_name="${GITHUB_REF_NAME:-}"
  local result_branch_name
  if [[ -n "$env_branch_name" ]]
  then
    result_branch_name="$env_branch_name"
  else
    result_branch_name="development"
  fi
  echo "$result_branch_name"
}

branch_name="$(get_branch_name)"

convert ${src_img} \
  -resize 640x480^ \
  -font Noto-Sans-Mono-Bold -pointsize 28 \
  -background black -gravity center -extent 640x480 \
  -colorspace sRGB -depth 8 \
  -gravity north -pointsize 20 -fill white \
    -annotate +0+10 "https://github.com/Sheridan/cephos" \
  -gravity south -pointsize 20 -fill white \
    -annotate +190+35 "https://t.me/ceph_os" \
  -gravity south -pointsize 20 -fill white \
    -annotate -190+35 "Version: ${branch_name}" \
  ${dst_img}
