#!/usr/bin/env bash


TIER='tosser'
VERSION='1.1234'
CONFIG_FILE='test2.json'
AWS_BUCKET='s3://andy-devops/deploymentConfig'

#Get the tier information
if $INTERACTIVE; then
# Get the files version to deploy
  echo "Select which tag to deploy (latest, 1.0.0 etc)"
  read -p "Version ($VERSION): " I_VERSION
  VERSION=${I_VERSION:-$VERSION}

  # Get the environment tier to deploy
  echo "Select which tier to deploy (production, preproduction, uat, development)"
  read -p "Tier ($TIER): " I_TIER
  TIER=${I_TIER:-$TIER}

  # Confirm deployment
  read -r -p "Are you sure you want to deploy version '$VERSION' to '$TIER' [y/n]: " confirm
  if [[ ! $confirm =~ ^(yes|y)$ ]]
    then
      exit 1;
  fi
fi



echo 'Creating config entry...'

#Pull config file to temp directory
TEMP_DIR=$(mktemp -d)
$(AWS s3 cp "$AWS_BUCKET/$CONFIG_FILE" "$TEMP_DIR" --profile home > /dev/null)

#Extract the contents of the config file into variable
FILE_CONTENTS=$(cat "$TEMP_DIR/$CONFIG_FILE" | jq '.')

#Set Tier and Version to config
NEW_CONFIG=$(echo "$FILE_CONTENTS" | jq --arg TIER "$TIER" --arg VERSION "$VERSION" '.[$TIER]=$VERSION')

#echo "$NEW_CONFIG" | jq '.'

#Write new config to file and push back to AWS
echo "$NEW_CONFIG" > "$TEMP_DIR/$CONFIG_FILE"
aws s3 mv "$TEMP_DIR/$CONFIG_FILE" "$AWS_BUCKET/" --profile home
rm -rf $TEMP_DIR

echo 'Operation complete.'
echo 'New config:'
echo "$NEW_CONFIG" | jq '.'
exit