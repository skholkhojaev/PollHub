document.addEventListener('DOMContentLoaded', function() {
  // Check for saved dark mode preference
  const savedTheme = localStorage.getItem('theme');
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
  
  // Apply theme based on preference or system setting
  if (savedTheme === 'dark' || (savedTheme === null && prefersDark)) {
    document.body.classList.add('dark-mode');
  }
  
  // Create dark mode toggle button and add to navbar
  const createToggleButton = () => {
    const navbarNavs = document.querySelectorAll('.navbar-nav');
    if (navbarNavs.length === 0) return;
    
    // Add to the last navbar-nav (usually the right-aligned one)
    const navbar = navbarNavs[navbarNavs.length - 1];
    
    const toggleContainer = document.createElement('li');
    toggleContainer.className = 'nav-item';
    
    const toggleButton = document.createElement('button');
    toggleButton.className = 'dark-mode-toggle nav-link';
    toggleButton.setAttribute('aria-label', 'Toggle dark mode');
    
    // Create icons for light/dark mode
    const isDarkMode = document.body.classList.contains('dark-mode');
    updateToggleButton(toggleButton, isDarkMode);
    
    toggleButton.addEventListener('click', () => {
      // Add transition class for smooth transition
      document.body.classList.add('theme-transition');
      
      // Toggle dark mode class
      const willBeDarkMode = !document.body.classList.contains('dark-mode');
      document.body.classList.toggle('dark-mode');
      
      // Update button appearance with animation
      updateToggleButton(toggleButton, willBeDarkMode);
      
      // Save preference to localStorage
      localStorage.setItem('theme', willBeDarkMode ? 'dark' : 'light');
      
      // Remove transition class after animation completes
      setTimeout(() => {
        document.body.classList.remove('theme-transition');
      }, 500);
    });
    
    toggleContainer.appendChild(toggleButton);
    navbar.appendChild(toggleContainer);
  };
  
  // Function to update the toggle button appearance
  function updateToggleButton(button, isDarkMode) {
    if (isDarkMode) {
      button.innerHTML = '<span class="toggle-icon">☀️</span>';
      button.setAttribute('title', 'Switch to light mode');
    } else {
      button.innerHTML = '<span class="toggle-icon">🌙</span>';
      button.setAttribute('title', 'Switch to dark mode');
    }
    
    // Add animation
    const icon = button.querySelector('.toggle-icon');
    icon.style.animation = 'none';
    setTimeout(() => {
      icon.style.animation = isDarkMode ? 'spin-in 0.5s forwards' : 'spin-in 0.5s forwards';
    }, 10);
  }
  
  // Add styles for the animation
  const style = document.createElement('style');
  style.textContent = `
    .theme-transition * {
      transition: background-color 0.5s ease, color 0.5s ease, border-color 0.5s ease, box-shadow 0.5s ease !important;
    }
    
    .toggle-icon {
      display: inline-block;
    }
    
    @keyframes spin-in {
      0% { transform: rotate(0deg) scale(0.5); opacity: 0; }
      100% { transform: rotate(360deg) scale(1); opacity: 1; }
    }
  `;
  document.head.appendChild(style);
  
  // Initialize the toggle button with a small delay to ensure DOM is ready
  setTimeout(createToggleButton, 100);
}); 