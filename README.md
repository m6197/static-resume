# Modern Resume Template

A beautiful, responsive HTML/CSS resume template with dynamic theme switching, data separation, and AWS deployment capabilities.

## 🚀 Quick Start

### Local Development

**Option 1: Direct File Access (Simplest)**
1. Clone or download this repository
2. Copy `config.template.json` to `config.json`
3. Edit `config.json` with your personal information
4. Run: `node sync-config.js` (syncs data for offline use)
5. Double-click `index.html` - works without any server!

**Option 2: Local Server (Recommended)**
1. Follow steps 1-3 above
2. Run: `python3 -m http.server 8000`
3. Open: http://localhost:8000

### AWS Deployment
1. Configure AWS CLI: `aws configure`
2. Run: `cd infrastructure && ./deploy.sh`
3. Your resume will be live on CloudFront with HTTPS

## 📁 Project Structure

```
resume-template/
├── index.html                    # Main resume HTML file
├── config.json                   # Personal data (excluded from git)
├── config.template.json          # Template for personal data
├── css/
│   └── styles.css               # Main stylesheet
├── js/
│   ├── theme-switcher.js        # Theme switching functionality
│   └── data-loader.js           # Dynamic data loading
├── assets/
│   └── images/                  # Profile photos and images
├── themes/                      # Theme variations
│   ├── modern-blue.css
│   ├── professional-dark.css
│   ├── minimal-green.css
│   └── corporate-navy.css
├── infrastructure/              # AWS deployment
│   ├── resume-website.yaml      # CloudFormation template
│   └── deploy.sh               # Deployment script
├── .github/workflows/
│   └── deploy.yml              # GitHub Actions deployment
├── README.md                   # This file
└── .gitignore                 # Git ignore file
```

## 🎨 Features

- **Dynamic Theme Switching** - 4 beautiful themes with instant switching
- **Data Separation** - Personal data kept separate from template code
- **AWS Deployment Ready** - CloudFormation template with best practices
- **Responsive Design** - Looks great on desktop, tablet, and mobile
- **Modern Aesthetic** - Clean, professional design with subtle animations
- **Print-Friendly** - Optimized for printing to PDF
- **Centered Timeline** - Beautiful alternating timeline for experience
- **Skill Tags** - Visual skill representation with color-coded categories
- **Certification Section** - Dedicated space for professional certifications
- **GitHub Actions** - Automated deployment pipeline

## 🛠️ Customization

### Personal Information
All personal data is stored in `config.json`. Copy `config.template.json` to `config.json` and customize:

```json
{
  "personal": {
    "name": "Your Full Name",
    "title": "Your Professional Title",
    "location": "Your City, Country",
    "email": "your.email@domain.com",
    "linkedin": "linkedin.com/in/yourprofile",
    "profileImage": "assets/images/profile.jpg",
    "profileInitials": "YN"
  },
  "summary": "Your professional summary...",
  "experience": [...],
  "skills": [...],
  "certifications": [...],
  "education": {...}
}
```

### Theme Customization
Create new themes by copying existing theme files in the `themes/` directory. Each theme uses CSS variables:

```css
:root {
    --primary-color: #667eea;
    --secondary-color: #764ba2;
    --accent-color: #28a745;
    --dark-color: #2c3e50;
    --light-bg: #f8f9fa;
    --text-color: #333;
}
```

### Adding Profile Image
1. Place your image in `assets/images/` (e.g., `profile.jpg`)
2. Update `config.json`:
   ```json
   {
     "personal": {
       "profileImage": "assets/images/profile.jpg",
       "profileInitials": "YN"
     }
   }
   ```
3. **Important:** Run `node sync-config.js` after updating config.json
4. Recommended size: 150x150px or larger (square format)

### Data Management
- **config.template.json** - Template with dummy data (committed to git)
- **config.json** - Your personal data (excluded from git)
- **js/config-data.js** - Auto-generated fallback (excluded from git)
- **Sync command:** `node sync-config.js` - Run after editing config.json

**Privacy Protection:**
- ✅ Personal data never committed to git
- ✅ Template code is shareable publicly
- ✅ Only dummy/example data in repository
- ✅ Personal images excluded from git

**Why two files?**
- Enables direct file access (double-click index.html)
- Maintains server compatibility (local/AWS deployment)
- Same template works everywhere

## 🎭 Available Themes

- **Modern Blue** - Original blue gradient theme
- **Professional Dark** - Dark theme for modern look
- **Minimal Green** - Clean green theme
- **Corporate Navy** - Professional navy blue theme

### Creating New Themes
1. Copy an existing theme file from `themes/`
2. Modify the CSS variables
3. Add the new theme to the dropdown in `js/theme-switcher.js`

## 📱 Responsive Breakpoints

- **Desktop**: 1200px and above
- **Tablet**: 768px - 1199px
- **Mobile**: Below 768px

## 🖨️ Print Optimization

The template includes print-specific CSS:
- Removes background gradients
- Optimizes spacing for A4 paper
- Ensures all content fits properly
- Maintains professional appearance

To create a PDF:
1. Open in browser
2. Press Ctrl+P (Cmd+P on Mac)
3. Select "Save as PDF"
4. Choose appropriate settings

## 🚀 AWS Deployment

### Prerequisites
- AWS CLI configured (`aws configure`)
- Appropriate AWS permissions

### Manual Deployment

**Basic deployment (Melbourne region, all features enabled):**
```bash
cd infrastructure
./deploy.sh
```

**Deploy to different region:**
```bash
./deploy.sh --region us-west-2              # Deploy to US West (Oregon)
./deploy.sh --region eu-west-1              # Deploy to EU (Ireland)
./deploy.sh --region ap-northeast-1         # Deploy to Asia Pacific (Tokyo)
```

**With custom domain:**
```bash
./deploy.sh --domain resume.example.com --hosted-zone-id Z1234567890 --certificate-arn arn:aws:acm:us-east-1:123456789:certificate/...
```

**Minimal deployment (no WAF, no Route 53, no access logs):**
```bash
./deploy.sh --disable-waf --disable-route53 --disable-access-logs
```

**Full custom configuration:**
```bash
./deploy.sh --region ap-southeast-2 --environment prod --project-name my-resume --enable-waf false
```

### GitHub Actions Deployment
1. Fork this repository
2. **Add GitHub Secrets:**
   - `AWS_ROLE_ARN`: IAM role for deployment
   - `PERSONAL_NAME`, `PERSONAL_TITLE`, etc.: Your personal data
   - `DOMAIN_NAME`, `HOSTED_ZONE_ID`, `CERTIFICATE_ARN`: For custom domain
3. **Add GitHub Variables (optional):**
   - `AWS_REGION`: AWS region (default: ap-southeast-2)
   - `ENABLE_WAF`: true/false (default: false)
   - `ENABLE_ROUTE53`: true/false (default: true)
   - `ENABLE_ACCESS_LOGS`: true/false (default: true)
   - `ENVIRONMENT`: dev/staging/prod (default: prod)
   - `PROJECT_NAME`: Project name for cost tracking (default: resume-website)
4. Push to main branch to trigger deployment

### Infrastructure Features

**Core Features (Always Enabled):**
- ✅ S3 static website hosting with encryption
- ✅ CloudFront CDN with HTTP/2, HTTP/3, and gzip
- ✅ SSL/TLS certificate support (custom or CloudFront default)
- ✅ Origin Access Control (OAC) for security
- ✅ Custom error pages (404/403 → index.html)
- ✅ Automated cache invalidation

**Optional Features (Configurable):**
- 🔧 **Route 53 DNS** - Custom domain configuration (enabled by default)
- 🔧 **WAF Protection** - Rate limiting and common attack protection (disabled by default)
- 🔧 **Access Logs** - CloudFront and S3 access logging (enabled by default)

**Cost Optimization:**
- Deploy to cheaper regions (Melbourne/Sydney often more cost-effective than US)
- WAF disabled by default (saves ~$5-10/month, enable with `--enable-waf true`)
- Route 53: ~$0.50/month per hosted zone (only needed with custom domains)
- Access Logs: Minimal storage costs for log files

**Region Selection:**
- **ap-southeast-2** (Melbourne): Default, often cost-effective for Australian users
- **us-east-1** (N. Virginia): Cheapest overall, but higher latency for Australian users
- **us-west-2** (Oregon): Good balance of cost and latency for US users
- **eu-west-1** (Ireland): Good for European users

**Important:** ACM certificates for CloudFront must be created in us-east-1 regardless of deployment region

## 🔧 Browser Support

- Chrome (recommended)
- Firefox
- Safari
- Edge
- Internet Explorer 11+

## 🔒 Privacy & Security

**Data Protection:**
- Personal data (`config.json`) is excluded from version control
- Generated fallback file (`js/config-data.js`) is also excluded from git
- Template code can be safely shared publicly

**Security Considerations:**
- **Direct file access:** Data embedded in JavaScript (viewable in source)
- **Server deployment:** Data loaded via secure JSON (preferred)
- **Production tip:** Remove `js/config-data.js` before AWS deployment for extra privacy

**AWS Security:**
- WAF protection against common attacks
- HTTPS-only with modern TLS
- S3 bucket encryption and access controls

## 🏗️ Architecture

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│   Route 53  │────│  CloudFront  │────│     S3      │
│     DNS     │    │     CDN      │    │   Bucket    │
└─────────────┘    └──────────────┘    └─────────────┘
                           │
                   ┌──────────────┐
                   │     WAF      │
                   │  Protection  │
                   └──────────────┘
```

## 📝 License

This template is free to use for personal and commercial purposes. Attribution appreciated but not required.

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

---

**Made with ❤️ for professional developers and architects**