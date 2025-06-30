// JavaScript for the Start Good Now Website
// Comprehensive interactive functionality

/* ===== UTILITY FUNCTIONS ===== */

// DOM Ready function
function domReady(fn) {
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', fn);
  } else {
    fn();
  }
}

// Smooth scroll to element
function smoothScrollTo(element) {
  if (element) {
    element.scrollIntoView({ behavior: 'smooth' });
  }
}

// Debounce function for performance
function debounce(func, wait) {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
}

/* ===== MOBILE NAVIGATION ===== */

function initMobileNavigation() {
  const mobileNavToggle = document.querySelector('.mobile-nav-toggle');
  const navMenu = document.querySelector('.nav-menu');
  const navLinks = document.querySelectorAll('.nav-menu a');

  if (mobileNavToggle && navMenu) {
    // Toggle menu on button click
    mobileNavToggle.addEventListener('click', () => {
      navMenu.classList.toggle('nav-menu-visible');
      mobileNavToggle.classList.toggle('active');
      
      // Update ARIA attributes for accessibility
      const isExpanded = navMenu.classList.contains('nav-menu-visible');
      mobileNavToggle.setAttribute('aria-expanded', isExpanded);
    });

    // Close menu when clicking nav links
    navLinks.forEach(link => {
      link.addEventListener('click', () => {
        navMenu.classList.remove('nav-menu-visible');
        mobileNavToggle.classList.remove('active');
        mobileNavToggle.setAttribute('aria-expanded', 'false');
      });
    });

    // Close menu when clicking outside
    document.addEventListener('click', (e) => {
      if (!mobileNavToggle.contains(e.target) && !navMenu.contains(e.target)) {
        navMenu.classList.remove('nav-menu-visible');
        mobileNavToggle.classList.remove('active');
        mobileNavToggle.setAttribute('aria-expanded', 'false');
      }
    });
  }
}

/* ===== SMOOTH SCROLLING FOR NAVIGATION ===== */

function initSmoothScrolling() {
  const navLinks = document.querySelectorAll('a[href^="#"]');
  
  navLinks.forEach(link => {
    link.addEventListener('click', (e) => {
      e.preventDefault();
      const targetId = link.getAttribute('href').substring(1);
      const targetElement = document.getElementById(targetId);
      
      if (targetElement) {
        // Offset for fixed header
        const headerHeight = document.querySelector('header')?.offsetHeight || 0;
        const elementPosition = targetElement.offsetTop - headerHeight - 20;
        
        window.scrollTo({
          top: elementPosition,
          behavior: 'smooth'
        });
      }
    });
  });
}

/* ===== FORM HANDLING ===== */

function initFormHandling() {
  // Community Starter Kit Form
  const starterKitForm = document.querySelector('#starter-kit-form');
  if (starterKitForm) {
    starterKitForm.addEventListener('submit', handleStarterKitSubmission);
  }

  // General Contact Form
  const contactForm = document.querySelector('#contact-form');
  if (contactForm) {
    contactForm.addEventListener('submit', handleContactSubmission);
  }

  // Newsletter signup
  const newsletterForm = document.querySelector('#newsletter-form');
  if (newsletterForm) {
    newsletterForm.addEventListener('submit', handleNewsletterSubmission);
  }
}

function handleStarterKitSubmission(event) {
  event.preventDefault();
  const formData = new FormData(event.target);
  
  // Basic validation
  if (!validateEmail(formData.get('email'))) {
    showNotification('Please enter a valid email address', 'error');
    return;
  }

  if (!formData.get('location') || formData.get('location').trim().length < 2) {
    showNotification('Please enter your location', 'error');
    return;
  }

  // Show loading state
  const submitButton = event.target.querySelector('button[type="submit"]');
  const originalText = submitButton.textContent;
  submitButton.textContent = 'Sending...';
  submitButton.disabled = true;

  // Send to server (placeholder - replace with actual endpoint)
  fetch('/api/starter-kit', {
    method: 'POST',
    body: formData
  })
  .then(response => {
    if (response.ok) {
      showNotification('Thank you! Your starter kit will be sent shortly.', 'success');
      event.target.reset();
    } else {
      throw new Error('Server error');
    }
  })
  .catch(error => {
    console.error('Error:', error);
    showNotification('Sorry, there was an error. Please try again.', 'error');
  })
  .finally(() => {
    submitButton.textContent = originalText;
    submitButton.disabled = false;
  });
}

function handleContactSubmission(event) {
  event.preventDefault();
  const formData = new FormData(event.target);
  
  if (!validateEmail(formData.get('email'))) {
    showNotification('Please enter a valid email address', 'error');
    return;
  }

  if (!formData.get('message') || formData.get('message').trim().length < 10) {
    showNotification('Please enter a message (at least 10 characters)', 'error');
    return;
  }

  // Similar handling as starter kit form
  showNotification('Thank you for your message! We\'ll get back to you soon.', 'success');
  event.target.reset();
}

function handleNewsletterSubmission(event) {
  event.preventDefault();
  const formData = new FormData(event.target);
  
  if (!validateEmail(formData.get('email'))) {
    showNotification('Please enter a valid email address', 'error');
    return;
  }

  showNotification('Thank you for subscribing to our newsletter!', 'success');
  event.target.reset();
}

function validateEmail(email) {
  const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return re.test(email);
}

/* ===== NOTIFICATION SYSTEM ===== */

function showNotification(message, type = 'info') {
  // Remove existing notifications
  const existingNotifications = document.querySelectorAll('.notification');
  existingNotifications.forEach(notif => notif.remove());

  // Create notification element
  const notification = document.createElement('div');
  notification.className = `notification notification-${type}`;
  notification.innerHTML = `
    <span>${message}</span>
    <button class="notification-close" aria-label="Close notification">&times;</button>
  `;

  // Add styles
  Object.assign(notification.style, {
    position: 'fixed',
    top: '20px',
    right: '20px',
    padding: '1rem 1.5rem',
    borderRadius: '8px',
    boxShadow: '0 4px 12px rgba(0,0,0,0.15)',
    zIndex: '10000',
    maxWidth: '400px',
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    fontWeight: '500',
    animation: 'slideInRight 0.3s ease-out'
  });

  // Set colors based on type
  if (type === 'success') {
    notification.style.backgroundColor = '#10b981';
    notification.style.color = 'white';
  } else if (type === 'error') {
    notification.style.backgroundColor = '#ef4444';
    notification.style.color = 'white';
  } else {
    notification.style.backgroundColor = '#3b82f6';
    notification.style.color = 'white';
  }

  // Add close functionality
  const closeButton = notification.querySelector('.notification-close');
  closeButton.style.background = 'none';
  closeButton.style.border = 'none';
  closeButton.style.color = 'inherit';
  closeButton.style.fontSize = '1.5rem';
  closeButton.style.cursor = 'pointer';
  closeButton.style.marginLeft = '1rem';
  
  closeButton.addEventListener('click', () => {
    notification.remove();
  });

  // Add to DOM
  document.body.appendChild(notification);

  // Auto-remove after 5 seconds
  setTimeout(() => {
    if (notification.parentNode) {
      notification.remove();
    }
  }, 5000);
}

/* ===== INTERACTIVE MAP ===== */

function initInteractiveMap() {
  const mapElement = document.querySelector('#interactive-map');
  
  if (mapElement) {
    // Placeholder for map initialization
    // This could be integrated with Google Maps, Mapbox, or Leaflet
    
    mapElement.innerHTML = `
      <div class="map-placeholder">
        <h3>Community Impact Map</h3>
        <p>Interactive map showing local initiatives will load here</p>
        <div class="map-controls">
          <button class="btn-secondary" onclick="loadMapData('sydney')">Sydney</button>
          <button class="btn-secondary" onclick="loadMapData('melbourne')">Melbourne</button>
          <button class="btn-secondary" onclick="loadMapData('brisbane')">Brisbane</button>
          <button class="btn-secondary" onclick="loadMapData('perth')">Perth</button>
        </div>
      </div>
    `;
    
    // Add some basic styling
    mapElement.style.minHeight = '400px';
    mapElement.style.backgroundColor = '#f8fafc';
    mapElement.style.border = '1px solid #e2e8f0';
    mapElement.style.borderRadius = '8px';
    mapElement.style.display = 'flex';
    mapElement.style.alignItems = 'center';
    mapElement.style.justifyContent = 'center';
    mapElement.style.textAlign = 'center';
  }
}

// Map data loading function (placeholder)
window.loadMapData = function(city) {
  showNotification(`Loading ${city} community data...`, 'info');
  // Implement actual map data loading here
};

/* ===== SCROLL ANIMATIONS ===== */

function initScrollAnimations() {
  const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
  };

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('animate-in');
      }
    });
  }, observerOptions);

  // Observe elements with animation classes
  const animatedElements = document.querySelectorAll('.fade-in, .slide-up, .bounce');
  animatedElements.forEach(el => {
    observer.observe(el);
  });
}

/* ===== MODAL FUNCTIONALITY ===== */

function initModalHandling() {
  // Open modal
  document.addEventListener('click', (e) => {
    if (e.target.matches('[data-modal-target]')) {
      const modalId = e.target.getAttribute('data-modal-target');
      const modal = document.getElementById(modalId);
      if (modal) {
        openModal(modal);
      }
    }
  });

  // Close modal
  document.addEventListener('click', (e) => {
    if (e.target.matches('[data-modal-close]') || e.target.matches('.modal-overlay')) {
      const modal = e.target.closest('.modal');
      if (modal) {
        closeModal(modal);
      }
    }
  });

  // Close modal with Escape key
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      const openModal = document.querySelector('.modal.active');
      if (openModal) {
        closeModal(openModal);
      }
    }
  });
}

function openModal(modal) {
  modal.classList.add('active');
  document.body.style.overflow = 'hidden';
  
  // Focus management for accessibility
  const focusableElements = modal.querySelectorAll('button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])');
  if (focusableElements.length > 0) {
    focusableElements[0].focus();
  }
}

function closeModal(modal) {
  modal.classList.remove('active');
  document.body.style.overflow = '';
}

/* ===== PERFORMANCE OPTIMIZATIONS ===== */

// Lazy loading for images
function initLazyLoading() {
  if ('IntersectionObserver' in window) {
    const imageObserver = new IntersectionObserver((entries, observer) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const img = entry.target;
          img.src = img.dataset.src;
          img.classList.remove('lazy');
          observer.unobserve(img);
        }
      });
    });

    const lazyImages = document.querySelectorAll('img[data-src]');
    lazyImages.forEach(img => imageObserver.observe(img));
  }
}

// Throttled scroll handler
const handleScroll = debounce(() => {
  const header = document.querySelector('header');
  if (header) {
    if (window.scrollY > 100) {
      header.classList.add('scrolled');
    } else {
      header.classList.remove('scrolled');
    }
  }
}, 100);

/* ===== INITIALIZATION ===== */

domReady(() => {
  console.log('Start Good Now website initialized');
  
  // Initialize all functionality
  initMobileNavigation();
  initSmoothScrolling();
  initFormHandling();
  initInteractiveMap();
  initScrollAnimations();
  initModalHandling();
  initLazyLoading();
  
  // Add scroll listener
  window.addEventListener('scroll', handleScroll);
  
  // Add resize listener for responsive adjustments
  window.addEventListener('resize', debounce(() => {
    // Handle responsive adjustments if needed
    console.log('Window resized');
  }, 250));
});

/* ===== EXPORT FOR TESTING ===== */

if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    validateEmail,
    showNotification,
    debounce
  };
}

