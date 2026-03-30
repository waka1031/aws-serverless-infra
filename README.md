# Terraform

AWS サーバーレスインフラの Terraform 定義。

## アーキテクチャ

```
CloudFront → S3 (Frontend)
CloudFront → API Gateway (REST API) → Lambda → RDS Data API → Aurora Serverless v2
```

## モジュール構成

| モジュール | 説明 |
|-----------|------|
| api_gateway | REST API + Lambda 統合 + API Key |
| aurora | Aurora Serverless v2 (PostgreSQL) + Secrets Manager |
| frontend | S3 + CloudFront |
| lambda | Lambda + IAM + CloudWatch Logs |
| vpc | VPC + プライベートサブネット |

## 使い方

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

## 必要な環境

- Terraform ~> 1.14
- AWS CLI（認証設定済み）
