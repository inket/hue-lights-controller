#!/usr/bin/env bash

# Docs for getting token https://developers.meethue.com/documentation/getting-started
# Possible Light States https://github.com/sqmk/huejay#lights

# Detects Bridge IP automatically
bridgeIP=$(curl -s https://discovery.meethue.com | cut -d: -f3 | tr -d '"}]')

source ~/.huerc

if [ ! "$HUE_USERNAME" ]
then
  echo "Must specify HUE_USERNAME in ~/.huerc" >&2
  exit 1
fi

# REQUIRED - Get your own token, see link at the top
username="$HUE_USERNAME"

function getLightsInfo {
  # Get all light attributes
  curl -s http://$bridgeIP/api/$username/lights/
}

# My Light ID's, yours will differ. Call getLightsInfo
lights=(3 4 5)

lightID=$2

function getLightStatus {
  curl -s http://$bridgeIP/api/$username/lights/$lightID
}

function getAllLightStatus {
  # Get individual attributes
  for i in ${lights[@]}
  do
    curl -s http://$bridgeIP/api/$username/lights/$i
  done
}

function lightOn {
  # Turn on single light
  curl -H 'Content-Type: application/json' -s -X PUT -d '{"on":true}' http://$bridgeIP/api/$username/lights/$lightID/state
}

function lightOff {
  # Turn off single light
  curl -H 'Content-Type: application/json' -s -X PUT -d '{"on":false}' http://$bridgeIP/api/$username/lights/$lightID/state
}

function lightBrighter {
  current_brightness=$(getLightStatus $lightID | jq ".state.bri")
  target_brightness=$((current_brightness + 50))
  result_brightness=$((target_brightness > 254 ? 254 : target_brightness))
  curl -H 'Content-Type: application/json' -s -X PUT -d "{\"bri\":$result_brightness}" http://$bridgeIP/api/$username/lights/$lightID/state
}

function lightDimmer {
  current_brightness=$(getLightStatus $lightID | jq ".state.bri")
  target_brightness=$((current_brightness - 50))
  result_brightness=$((target_brightness < 0 ? 0 : target_brightness))
  curl -H 'Content-Type: application/json' -s -X PUT -d "{\"bri\":$result_brightness}" http://$bridgeIP/api/$username/lights/$lightID/state
}

function lightsOn {
  for i in ${lights[@]}
  do
    curl -H 'Content-Type: application/json' -s -X PUT -d '{"on":true}' http://$bridgeIP/api/$username/lights/$i/state
  done
}

function lightsOff {
  for i in ${lights[@]}
  do
    curl -H 'Content-Type: application/json' -s -X PUT -d '{"on":false}' http://$bridgeIP/api/$username/lights/$i/state
  done
}

# Call Function
$1
