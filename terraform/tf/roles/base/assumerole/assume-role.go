package main

import (
	"fmt"
	"net/http"
	"os"
	"os/exec"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/sts"
	"github.com/sirupsen/logrus"
)

func main() {
	log := logrus.New()
	args := os.Args[1:]
	if len(args) != 3 {
		log.Fatal("command arguments required\n1) assuming role arn\n2) session name\n3)configuring profile name")
	}

	rlArn := args[0]
	sn := args[1]
	profile := args[2]
	region := "us-west-2"
	sess := session.Must(session.NewSession(&aws.Config{
		Region:     &region,
		HTTPClient: &http.Client{},
	}))

	client := sts.New(sess)

	ari := sts.AssumeRoleInput{
		DurationSeconds: aws.Int64(3600),
		RoleArn:         &rlArn,
		RoleSessionName: &sn,
	}

	out, err := client.AssumeRole(&ari)
	if err != nil {
		log.Fatalf("failed to assume role: %v", err)
	}
	setAccKeyId := exec.Command("aws", "configure", "set", "aws_access_key_id", *out.Credentials.AccessKeyId, fmt.Sprintf("--profile=%s", profile))

	err = setAccKeyId.Run()
	if err != nil {
		log.Fatalf("failed to set access key: %v", err)
	}

	setSecAccKey := exec.Command("aws", "configure", "set", "aws_secret_access_key", *out.Credentials.SecretAccessKey, fmt.Sprintf("--profile=%s", profile))

	err = setSecAccKey.Run()
	if err != nil {
		log.Fatalf("failed to set secret access key: %v", err)
	}

	setSession := exec.Command("aws", "configure", "set", "aws_session_token", *out.Credentials.SessionToken, fmt.Sprintf("--profile=%s", profile))

	err = setSession.Run()
	if err != nil {
		log.Fatalf("failed to set session token: %v", err)
	}

	log.Info(fmt.Sprintf("successfully reconfigured %s profile", profile))
}
