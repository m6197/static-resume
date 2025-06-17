document.addEventListener('DOMContentLoaded', function() {
    const themeSelect = document.getElementById('theme-select');
    const themeStylesheet = document.getElementById('theme-stylesheet');
    
    // Load saved theme from localStorage
    const savedTheme = localStorage.getItem('selectedTheme') || 'modern-blue';
    themeSelect.value = savedTheme;
    updateTheme(savedTheme);
    
    // Handle theme change
    themeSelect.addEventListener('change', function() {
        const selectedTheme = this.value;
        updateTheme(selectedTheme);
        localStorage.setItem('selectedTheme', selectedTheme);
    });
    
    function updateTheme(themeName) {
        themeStylesheet.href = `themes/${themeName}.css`;
    }
});