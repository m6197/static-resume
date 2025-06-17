#!/usr/bin/env node

/**
 * Sync script to convert config.json to config-data.js
 * This allows the resume to work with both direct file access and server environments
 */

const fs = require('fs');
const path = require('path');

function syncConfig() {
    try {
        // Read config.json
        const configPath = path.join(__dirname, 'config.json');
        if (!fs.existsSync(configPath)) {
            console.error('❌ config.json not found. Please create it from config.template.json');
            process.exit(1);
        }

        const configData = fs.readFileSync(configPath, 'utf8');
        const config = JSON.parse(configData);

        // Generate config-data.js content
        const jsContent = `// Configuration data - automatically generated from config.json
// This file allows the resume to work with direct file access
window.RESUME_CONFIG = ${JSON.stringify(config, null, 2)};`;

        // Write config-data.js
        const outputPath = path.join(__dirname, 'js', 'config-data.js');
        fs.writeFileSync(outputPath, jsContent);

        console.log('✅ Successfully synced config.json → js/config-data.js');
        console.log('📝 Resume will now work with both direct file access and server environments');
        
    } catch (error) {
        console.error('❌ Error syncing config:', error.message);
        process.exit(1);
    }
}

// Run if called directly
if (require.main === module) {
    syncConfig();
}

module.exports = { syncConfig };