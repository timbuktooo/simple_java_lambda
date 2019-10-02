#!/bin/sh 

function deployFail {
    echo "Deploy to AWS Lambda failed"
	exit 1
}

trap deployFail ERR

REGION="us-east-1"
CURDIR=`pwd`
ALIAS="DEV"
HANDLER="com.Hello::handleRequest"

BUILD_VERSION=$BUILD_NUMBER
LAMBDA_NAME=$JOB_NAME

FUNCTION_ARN=$(aws lambda get-function --region ${REGION} --function-name ${NAME} --output json| jq -r '.Configuration.FunctionArn')
if [[ ! -z $FUNCTION_ARN ]]; then
    echo "Function Exists"
    aws lambda update-function-code --region ${REGION} --function-name ${NAME} --zip-file fileb://target/${LAMBDA_NAME}-${BUILD_VERSION}.jar
    OUTPUT=$(aws lambda publish-version --region ${REGION} --function-name ${NAME} --description "${BUILD_VERSION} Build}")
  
    if [[ -e ${NAME}-${ALIAS}.txt ]]; then
        echo "${OUTPUT}" > $file
    else
        file="${NAME}-${ALIAS}.txt"
        echo "${OUTPUT}" > $file
        ls -al
    fi
  existing_aliases=$(aws lambda list-aliases --function-name ${NAME} --region ${REGION} --output json| jq -r '.Aliases[] | {Name: .Name}')
  if [[ $existing_aliases == *"$ALIAS"* ]]; then
    aws lambda update-alias --region ${REGION} --function-name ${NAME} --description "${BUILD_VERSION} Build" --function-version '$LATEST'  --name $ALIAS
  else
    aws lambda create-alias --region ${REGION} --function-name ${NAME} --description "${BUILD_VERSION} Build" --function-version '$LATEST' --name $ALIAS
  fi

else
    echo "Function Created"
    jq -n '{"Version": "2012-10-17","Statement": [{"Effect": "Allow","Principal": {"Service": "lambda.amazonaws.com"},"Action": "sts:AssumeRole"}]}' > trust.json
    aws iam create-role --role-name ${NAME}Role --assume-role-policy file://trust.json | echo "role exists"
    ROLE_ARN=$(aws iam get-role --role-name ${NAME}Role  --output json| jq -r '.Role.Arn')
    aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole --role-name ${NAME}Role
    sleep 20s
    
    FUNCTION_ARN=$(aws lambda create-function --region ${REGION} --function-name ${NAME} --role ${ROLE_ARN} --handler ${HANDLER} --runtime java8 --zip-file fileb://target/${LAMBDA_NAME}-${BUILD_VERSION}.jar --output json| jq -r '.FunctionArn')
    aws lambda create-alias --region ${REGION} --function-name ${NAME} --description "${BUILD_VERSION} Build" --function-version '$LATEST' --name $ALIAS

fi
echo "function arn=${FUNCTION_ARN}"



