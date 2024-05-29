#!/bin/bash

# export resourceGroupName=$resourceGroupName
# export location=$location
# export workloadName=$workloadName
# export workloadEnv=$workloadEnv
# export registryURI=$registryURI
# export imageName=$imageName
# export imageTag=$imageTag
# export GTIHUB_PAT=$GTIHUB_PAT
# export STORAGE_ACCOUNT=$STORAGE_ACCOUNT
# export AZURE_DEVOPS_ORGNAME=$AZURE_DEVOPS_ORGNAME
# export AZURE_DEVOPS_PAT=$AZURE_DEVOPS_PAT
# export AZURE_OPENAI_ENDPOINT=$AZURE_OPENAI_ENDPOINT
# export AZURE_OPENAI_API_KEY=$AZURE_OPENAI_API_KEY

uamiId=$(az identity show --resource-group $resourceGroupName --name ${workloadName}-uami-${workloadEnv} | jq -r '.id')
echo "UAMI ID: $uamiId"

CONNECTION_STRING=$(az storage account show-connection-string --resource-group $resourceGroupName --name $STORAGE_ACCOUNT --query connectionString --output tsv)


az container create \
    --resource-group $resourceGroupName \
    --name azure-lcm-$imageTag \
    --image $registryURI/$imageName:$imageTag \
    --assign-identity $uamiId \
    --acr-identity $uamiId \
    --ip-address Private \
    --restart-policy Never \
    --no-wait \
    --environment-variables \
    PROCESS_AZURE_POLICY=true \
    PROCESS_AZURE_FEED=true \
    GITHUB_PAT="$GTIHUB_PAT" \
    AZURE_POLICY_URI_BASE="https://api.github.com/repos/azure/azure-policy/contents/" \
    AZURE_POLICY_PATH="built-in-policies/policyDefinitions" \
    AZURE_UPDATE_FEED_URI="https://azurecomcdn.azureedge.net/en-us/updates/feed/" \
    AZURE_STORAGE_CONNECTION="$CONNECTION_STRING" \
    AZURE_STORAGE_FEED_TABLE_NAME="azupdatefeed" \
    AZURE_STORAGE_POLICY_TABLE_NAME="azpolicy" \
    AZURE_OPENAI_ENDPOINT="$AZURE_OPENAI_ENDPOINT" \
    AZURE_OPENAI_API_KEY="$AZURE_OPENAI_API_KEY" \
    AZURE_OPENAI_GPT_DEPLOYMENT_ID=gpt-35-turbo \
    AZURE_OPENAI_DAVINCI_DEPLOYMENT_ID=text-davinci-003 \
    AZURE_DEVOPS_ORGNAME=$AZURE_DEVOPS_ORGNAME \
    AZURE_DEVOPS_USE_PAT=true \
    AZURE_DEVOPS_USE_MANAGED_IDENTITY=false \
    AZURE_DEVOPS_USE_SERVICE_PRINCIPAL=false \
    AZURE_DEVOPS_PAT="$AZURE_DEVOPS_PAT" \
    FEED_PROMPT_TEMPLATE_URI=https://gist.githubusercontent.com/damayantiazure/a670277b14d68149040de09bff560a4f/raw/eeeb4b59e1e8cb94c441d4cc5609d3d3eec68fe1/FeedPromptTemplate.txt" \
    FEED_WORKITEM_TEMPLATE_URI="https://gist.githubusercontent.com/damayantiazure/524ce416fb3e63b07b6ce0b869fd321b/raw/ee64445ef5e5deb3cfc9fcbd0e0219fde80642be/FeedWorkItemTemplateNew.json" \
    POLICY_WORKITEM_TEMPLATE_URI="https://gist.githubusercontent.com/damayantiazure/ba95444da66ced0a02b176522b8f740c/raw/beb47c21948da7d43ec122858ff9465ae003f019/PolicyWorkItemTemplateNew.json"
