#!/bin/bash

# Resume Website Deployment Script
# This script deploys the CloudFormation stack and uploads website files

set -e

# Configuration
STACK_NAME="resume-website"
TEMPLATE_FILE="resume-website.yaml"
REGION="ap-southeast-2"  # Default to Melbourne region

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if AWS CLI is configured
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install it first."
        exit 1
    fi
    
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS CLI is not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    print_status "AWS CLI is configured"
}

# Function to validate CloudFormation template
validate_template() {
    print_status "Validating CloudFormation template..."
    if aws cloudformation validate-template --template-body file://"$TEMPLATE_FILE" --region "$REGION" &> /dev/null; then
        print_status "Template validation successful"
    else
        print_error "Template validation failed"
        exit 1
    fi
}

# Function to validate certificate region
validate_certificate() {
    if [ -n "$CERTIFICATE_ARN" ]; then
        # Extract region from certificate ARN
        cert_region=$(echo "$CERTIFICATE_ARN" | cut -d':' -f4)
        if [ "$cert_region" != "us-east-1" ]; then
            print_error "Certificate must be in us-east-1 region for CloudFront compatibility"
            print_error "Current certificate region: $cert_region"
            print_error "Please create a certificate in us-east-1 or omit --certificate-arn for CloudFront default certificate"
            exit 1
        fi
        print_status "Certificate region validation passed (us-east-1)"
    fi
}

# Function to deploy CloudFormation stack
deploy_stack() {
    local domain_name="$1"
    local hosted_zone_id="$2"
    local certificate_arn="$3"
    local enable_waf="$4"
    local enable_route53="$5"
    local enable_access_logs="$6"
    local environment="$7"
    local project_name="$8"
    
    print_status "Deploying CloudFormation stack: $STACK_NAME"
    
    local params=""
    if [ -n "$domain_name" ]; then
        params="$params ParameterKey=DomainName,ParameterValue=$domain_name"
    fi
    if [ -n "$hosted_zone_id" ]; then
        params="$params ParameterKey=HostedZoneId,ParameterValue=$hosted_zone_id"
    fi
    if [ -n "$certificate_arn" ]; then
        params="$params ParameterKey=CertificateArn,ParameterValue=$certificate_arn"
    fi
    if [ -n "$enable_waf" ]; then
        params="$params ParameterKey=EnableWAF,ParameterValue=$enable_waf"
    fi
    if [ -n "$enable_route53" ]; then
        params="$params ParameterKey=EnableRoute53,ParameterValue=$enable_route53"
    fi
    if [ -n "$enable_access_logs" ]; then
        params="$params ParameterKey=EnableAccessLogs,ParameterValue=$enable_access_logs"
    fi
    if [ -n "$environment" ]; then
        params="$params ParameterKey=Environment,ParameterValue=$environment"
    fi
    if [ -n "$project_name" ]; then
        params="$params ParameterKey=ProjectName,ParameterValue=$project_name"
    fi
    
    if [ -n "$params" ]; then
        aws cloudformation deploy \
            --template-file "$TEMPLATE_FILE" \
            --stack-name "$STACK_NAME" \
            --parameter-overrides $params \
            --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
            --region "$REGION"
    else
        aws cloudformation deploy \
            --template-file "$TEMPLATE_FILE" \
            --stack-name "$STACK_NAME" \
            --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
            --region "$REGION"
    fi
    
    print_status "Stack deployment completed"
}

# Function to get stack outputs
get_stack_outputs() {
    aws cloudformation describe-stacks \
        --stack-name "$STACK_NAME" \
        --region "$REGION" \
        --query 'Stacks[0].Outputs[?OutputKey==`BucketName`].OutputValue' \
        --output text
}

# Function to upload website files
upload_files() {
    local bucket_name="$1"
    
    print_status "Uploading website files to S3 bucket: $bucket_name"
    
    # Check if config.json exists
    if [ ! -f "../config.json" ]; then
        print_warning "config.json not found. Please create it from config.template.json"
        print_warning "The website will show an error until config.json is created"
    fi
    
    # Upload files with proper content types
    aws s3 sync .. s3://"$bucket_name" \
        --exclude "infrastructure/*" \
        --exclude ".git/*" \
        --exclude "*.md" \
        --exclude ".gitignore" \
        --exclude "deploy.sh" \
        --cache-control "public, max-age=31536000" \
        --region "$REGION"
    
    # Upload HTML files with shorter cache
    aws s3 cp ../index.html s3://"$bucket_name"/index.html \
        --content-type "text/html" \
        --cache-control "public, max-age=3600" \
        --region "$REGION"
    
    # Upload JSON files
    if [ -f "../config.json" ]; then
        aws s3 cp ../config.json s3://"$bucket_name"/config.json \
            --content-type "application/json" \
            --cache-control "public, max-age=3600" \
            --region "$REGION"
    fi
    
    print_status "File upload completed"
}

# Function to create CloudFront invalidation
create_invalidation() {
    local distribution_id
    distribution_id=$(aws cloudformation describe-stacks \
        --stack-name "$STACK_NAME" \
        --region "$REGION" \
        --query 'Stacks[0].Outputs[?OutputKey==`CloudFrontDistributionId`].OutputValue' \
        --output text)
    
    if [ -n "$distribution_id" ]; then
        print_status "Creating CloudFront invalidation for distribution: $distribution_id"
        aws cloudfront create-invalidation \
            --distribution-id "$distribution_id" \
            --paths "/*" \
            --region "$REGION" > /dev/null
        print_status "Invalidation created"
    fi
}

# Function to display final URLs
display_urls() {
    local website_url
    website_url=$(aws cloudformation describe-stacks \
        --stack-name "$STACK_NAME" \
        --region "$REGION" \
        --query 'Stacks[0].Outputs[?OutputKey==`WebsiteURL`].OutputValue' \
        --output text)
    
    echo
    print_status "Deployment completed successfully!"
    echo -e "${GREEN}Website URL: ${NC}$website_url"
    echo
}

# Main execution
main() {
    cd "$(dirname "$0")"
    
    print_status "Starting resume website deployment..."
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --domain)
                DOMAIN_NAME="$2"
                shift 2
                ;;
            --hosted-zone-id)
                HOSTED_ZONE_ID="$2"
                shift 2
                ;;
            --certificate-arn)
                CERTIFICATE_ARN="$2"
                shift 2
                ;;
            --enable-waf)
                ENABLE_WAF="$2"
                shift 2
                ;;
            --enable-route53)
                ENABLE_ROUTE53="$2"
                shift 2
                ;;
            --enable-access-logs)
                ENABLE_ACCESS_LOGS="$2"
                shift 2
                ;;
            --environment)
                ENVIRONMENT="$2"
                shift 2
                ;;
            --project-name)
                PROJECT_NAME="$2"
                shift 2
                ;;
            --region)
                REGION="$2"
                shift 2
                ;;
            --disable-waf)
                ENABLE_WAF="false"
                shift
                ;;
            --disable-route53)
                ENABLE_ROUTE53="false"
                shift
                ;;
            --disable-access-logs)
                ENABLE_ACCESS_LOGS="false"
                shift
                ;;
            --help)
                echo "Usage: $0 [OPTIONS]"
                echo "Options:"
                echo "  --domain DOMAIN_NAME              Custom domain name (optional)"
                echo "  --hosted-zone-id HOSTED_ZONE_ID   Route 53 Hosted Zone ID (required with --domain)"
                echo "  --certificate-arn CERTIFICATE_ARN ACM Certificate ARN (required with --domain)"
                echo "  --enable-waf true|false           Enable WAF protection (default: true)"
                echo "  --enable-route53 true|false       Enable Route 53 DNS (default: true)"
                echo "  --enable-access-logs true|false   Enable access logging (default: true)"
                echo "  --environment ENV                 Environment name: dev|staging|prod (default: prod)"
                echo "  --project-name NAME               Project name for cost tracking (default: resume-website)"
                echo "  --region REGION                   AWS region (default: ap-southeast-2)"
                echo "  --disable-waf                     Shortcut to disable WAF"
                echo "  --disable-route53                 Shortcut to disable Route 53"
                echo "  --disable-access-logs             Shortcut to disable access logs"
                echo "  --help                             Show this help message"
                echo ""
                echo "Examples:"
                echo "  $0                                 # Deploy to Melbourne (ap-southeast-2) with all features"
                echo "  $0 --region us-west-2              # Deploy to US West (Oregon)"
                echo "  $0 --disable-waf --disable-route53 # Deploy without WAF and Route 53"
                echo "  $0 --domain resume.example.com --hosted-zone-id Z123 --certificate-arn arn:aws:acm:us-east-1:..."
                echo ""
                echo "Note: ACM certificates for CloudFront must be created in us-east-1 region"
                exit 0
                ;;
            *)
                print_error "Unknown option $1"
                exit 1
                ;;
        esac
    done
    
    # Validate dependencies
    check_aws_cli
    validate_template
    validate_certificate
    
    # Deploy infrastructure
    deploy_stack "$DOMAIN_NAME" "$HOSTED_ZONE_ID" "$CERTIFICATE_ARN" "$ENABLE_WAF" "$ENABLE_ROUTE53" "$ENABLE_ACCESS_LOGS" "$ENVIRONMENT" "$PROJECT_NAME"
    
    # Get bucket name from stack outputs
    BUCKET_NAME=$(get_stack_outputs)
    
    if [ -z "$BUCKET_NAME" ]; then
        print_error "Failed to get bucket name from stack outputs"
        exit 1
    fi
    
    # Upload website files
    upload_files "$BUCKET_NAME"
    
    # Create CloudFront invalidation
    create_invalidation
    
    # Display final information
    display_urls
}

# Run main function
main "$@"