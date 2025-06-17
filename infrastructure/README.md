# Infrastructure Documentation

## Overview

This directory contains AWS infrastructure templates and deployment scripts for hosting the resume website.

## Files

- `resume-website.yaml` - CloudFormation template with configurable features
- `deploy.sh` - Deployment script with parameter support

## Configuration Options

### Required Parameters
- None (all parameters have defaults)

### Optional Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `DomainName` | `""` | Custom domain name (e.g., resume.example.com) |
| `HostedZoneId` | `""` | Route 53 Hosted Zone ID |
| `CertificateArn` | `""` | ACM Certificate ARN (must be in us-east-1) |
| `EnableWAF` | `true` | Enable WAF Web ACL protection |
| `EnableRoute53` | `true` | Enable Route 53 DNS record creation |
| `EnableAccessLogs` | `true` | Enable CloudFront access logging |

## Deployment Examples

### Minimal Deployment (Cost-Optimized)
```bash
./deploy.sh --disable-route53 --disable-access-logs
```
**Cost:** ~$0.50/month (CloudFront + S3, WAF already disabled by default)

### Standard Deployment
```bash
./deploy.sh
```
**Cost:** ~$1-2/month (no WAF, includes Route 53 and logging)

### Enhanced Security Deployment
```bash
./deploy.sh --enable-waf true
```
**Cost:** ~$6-12/month (includes WAF protection)

### Enterprise Deployment with Custom Domain
```bash
./deploy.sh \
  --domain resume.company.com \
  --hosted-zone-id Z1D633PJN98FT9 \
  --certificate-arn arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012
```

## Resource Architecture

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Route 53  │────│ CloudFront  │────│     S3      │
│     DNS     │    │     CDN     │    │   Bucket    │
└─────────────┘    └─────────────┘    └─────────────┘
                           │
                   ┌─────────────┐
                   │     WAF     │
                   │ Protection  │
                   └─────────────┘
```

## Security Features

### Always Enabled
- S3 bucket encryption (AES-256)
- CloudFront HTTPS redirect
- Origin Access Control (OAC)
- S3 public access blocked
- Security response headers

### Optional (WAF)
- Rate limiting (2000 requests/5 minutes per IP)
- AWS Managed Rules for common attacks
- CloudWatch metrics and logging

## Cost Breakdown

| Service | Monthly Cost (Estimate) |
|---------|-------------------------|
| S3 Storage (1GB) | $0.023 |
| CloudFront (10GB transfer) | $0.85 |
| Route 53 Hosted Zone | $0.50 |
| WAF Web ACL | $5.00 + $0.60/million requests |
| CloudWatch Logs | $0.50-2.00 |

## Monitoring

The template includes CloudWatch integration for:
- CloudFront access patterns
- WAF blocked requests
- S3 bucket activity
- Performance metrics

## Troubleshooting

### Common Issues

1. **Certificate validation fails**
   - Ensure certificate is in us-east-1 region
   - Verify certificate covers the domain name

2. **Route 53 record creation fails**
   - Check HostedZoneId is correct
   - Verify domain name matches hosted zone

3. **WAF blocks legitimate traffic**
   - Review WAF logs in CloudWatch
   - Adjust rate limiting rules if needed

### Useful Commands

```bash
# Validate template
aws cloudformation validate-template --template-body file://resume-website.yaml

# Check stack status
aws cloudformation describe-stacks --stack-name resume-website

# View stack events
aws cloudformation describe-stack-events --stack-name resume-website

# Delete stack
aws cloudformation delete-stack --stack-name resume-website
```