document.addEventListener('DOMContentLoaded', function() {
    loadResumeData();
});

async function loadResumeData() {
    // Try to load from config.json first (for server environments)
    try {
        const response = await fetch('config.json');
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const data = await response.json();
        
        populatePersonalInfo(data.personal);
        populateSummary(data.summary);
        populateExperience(data.experience);
        populateSkills(data.skills);
        populateCertifications(data.certifications);
        populateEducation(data.education);
        
        return; // Success - exit function
        
    } catch (error) {
        console.log('Could not load config.json, trying fallback data...', error);
        
        // Fallback to embedded data (for direct file access)
        if (window.RESUME_CONFIG) {
            console.log('Using embedded configuration data');
            const data = window.RESUME_CONFIG;
            
            populatePersonalInfo(data.personal);
            populateSummary(data.summary);
            populateExperience(data.experience);
            populateSkills(data.skills);
            populateCertifications(data.certifications);
            populateEducation(data.education);
            
            return; // Success with fallback
        }
        
        // Both methods failed
        console.error('Error loading resume data:', error);
        showErrorMessage();
    }
}

function populatePersonalInfo(personal) {
    // Update page title
    document.title = `${personal.name} - ${personal.title}`;
    
    // Profile image or initials
    const profilePicture = document.getElementById('profile-picture');
    const profileInitials = document.getElementById('profile-initials');
    
    if (personal.profileImage) {
        profilePicture.src = personal.profileImage;
        profilePicture.alt = personal.name;
        profilePicture.style.display = 'block';
        profileInitials.style.display = 'none';
        
        // Fallback to initials if image fails to load
        profilePicture.onerror = function() {
            profilePicture.style.display = 'none';
            profileInitials.style.display = 'flex';
            profileInitials.textContent = personal.profileInitials;
        };
    } else {
        profilePicture.style.display = 'none';
        profileInitials.style.display = 'flex';
        profileInitials.textContent = personal.profileInitials;
    }
    
    // Personal information
    document.getElementById('name-display').textContent = personal.name;
    document.getElementById('title-display').textContent = personal.title;
    document.getElementById('location-display').textContent = personal.location;
    document.getElementById('email-display').textContent = personal.email;
    document.getElementById('linkedin-display').textContent = personal.linkedin;
}

function populateSummary(summary) {
    document.getElementById('summary-display').textContent = summary;
}

function populateExperience(experience) {
    const timeline = document.getElementById('experience-timeline');
    timeline.innerHTML = '';
    
    experience.forEach(job => {
        const timelineItem = document.createElement('div');
        timelineItem.className = 'timeline-item';
        
        timelineItem.innerHTML = `
            <div class="job-title">${job.title}</div>
            <div class="company">${job.company}</div>
            <div class="duration">${job.duration}</div>
        `;
        
        timeline.appendChild(timelineItem);
    });
}

function populateSkills(skills) {
    const skillsGrid = document.getElementById('skills-grid');
    skillsGrid.innerHTML = '';
    
    skills.forEach(skillCategory => {
        const categoryDiv = document.createElement('div');
        categoryDiv.className = 'skill-category';
        
        const tagsHtml = skillCategory.tags.map(tag => 
            `<span class="skill-tag">${tag}</span>`
        ).join('');
        
        categoryDiv.innerHTML = `
            <h4>${skillCategory.category}</h4>
            <div class="skill-tags">
                ${tagsHtml}
            </div>
        `;
        
        skillsGrid.appendChild(categoryDiv);
    });
}

function populateCertifications(certifications) {
    const certGrid = document.getElementById('certifications-grid');
    certGrid.innerHTML = '';
    
    certifications.forEach(cert => {
        const certItem = document.createElement('div');
        certItem.className = 'cert-item';
        
        certItem.innerHTML = `
            <div class="cert-name">${cert.name}</div>
            <div class="cert-year">${cert.year}</div>
        `;
        
        certGrid.appendChild(certItem);
    });
}

function populateEducation(education) {
    const educationDiv = document.getElementById('education-display');
    
    educationDiv.innerHTML = `
        <h4>${education.degree}</h4>
        <p>${education.field}</p>
        <p>${education.institution}, ${education.year}</p>
    `;
}

function showErrorMessage() {
    const container = document.querySelector('.container');
    container.innerHTML = `
        <div style="text-align: center; padding: 2rem; color: #e74c3c;">
            <h2>Configuration Error</h2>
            <p>Unable to load resume data. Please ensure config.json exists and is properly formatted.</p>
            <p>Copy config.template.json to config.json and customize with your information.</p>
        </div>
    `;
}

function showLocalFileError() {
    const container = document.querySelector('.container');
    container.innerHTML = `
        <div style="text-align: center; padding: 2rem; color: #e74c3c;">
            <h2>Local File Access Error</h2>
            <p>Browsers block loading JSON files locally for security reasons.</p>
            <h3>Solutions:</h3>
            <div style="text-align: left; max-width: 600px; margin: 0 auto; background: #f8f9fa; padding: 1.5rem; border-radius: 8px;">
                <p><strong>Option 1: Use a local web server</strong></p>
                <code style="background: #2c3e50; color: white; padding: 0.5rem; display: block; margin: 0.5rem 0;">
                    cd ${window.location.pathname.split('/').slice(0, -1).join('/')}<br>
                    python3 -m http.server 8000
                </code>
                <p>Then open: <a href="http://localhost:8000">http://localhost:8000</a></p>
                
                <p><strong>Option 2: Use Live Server (VS Code)</strong></p>
                <p>Install "Live Server" extension and right-click index.html → "Open with Live Server"</p>
                
                <p><strong>Option 3: Use Chrome with disabled security</strong></p>
                <code style="background: #2c3e50; color: white; padding: 0.5rem; display: block; margin: 0.5rem 0;">
                    open /Applications/Google\\ Chrome.app --args --disable-web-security --user-data-dir=/tmp/chrome_dev
                </code>
            </div>
        </div>
    `;
}