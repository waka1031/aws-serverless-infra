terraform {
  backend "s3" {
    bucket = "nba-moments-s3-tfstate"
    key    = "dev/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
