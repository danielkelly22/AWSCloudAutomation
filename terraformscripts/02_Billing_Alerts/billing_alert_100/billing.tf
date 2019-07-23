terraform {
  required_version = ">= 0.10.3"

  backend "s3" {
    bucket = "amtrust-tf-state"
    key = "billing_alerts/alert_100/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "billing_alarm" {
  source = "../modules/billing_alarm"
  
  aws_env = "dev"
  # Alarm when estimated monthly charges are above this amount
  monthly_billing_threshold = 5000
  # Currency is optional and defaults to USD
  currency = "USD"
  sns_topic_arn="${module.billing_sns.sns_topic_arn}"
}

module "billing_sns" {
source = "../modules/sns_topic"
display_name="billing_alarm_sns_100"
subscriptions=["AmTrustCloudTeam@amtrustgroup.com"]
stack_name="billing-sns-alarm-100"
 tags = {
    Location= "EastUS1"
    BusinessUnit= "Claims"
    Environment= "prod"
    CostCenter= "AM00001"
    ApplicationName= "CPP"
    ApplicationOwner= "appteam@amtrustgroup.com"
    InfrastructureOwner= "cloudteam@amtrustgroup.com"
    AssetRole= "WebServer"
    MaintWindow= "SAT,23:00EST"
    SupportSLA= "Mo-Sa,6:00-23:00EST"
    BusinessContinuity= "C1"
  }
 
}