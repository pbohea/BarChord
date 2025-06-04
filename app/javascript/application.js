// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Change to true to allow Turbo
Turbo.session.drive = true

// Allow UJS alongside Turbo
import jquery from "jquery";
window.jQuery = jquery;
window.$ = jquery;
import Rails from "@rails/ujs"
Rails.start();



document.addEventListener("turbo:load", () => {
  document.querySelectorAll('.alert').forEach((alert) => {
    setTimeout(() => {
      alert.classList.remove('show')
      setTimeout(() => alert.remove(), 300)
    }, 3000)
  });
});

document.addEventListener("turbo:frame-render", (event) => {
  const frame = event.target
  if (frame.id && frame.id.startsWith("follow_button_")) {
    const btn = frame.querySelector("form button")
    if (btn) {
      btn.classList.add("btn-follow-animate")
      setTimeout(() => btn.classList.remove("btn-follow-animate"), 200)
    }
  }
})


// Add this to your application.js or create a separate native.js file

// Detect if running in native app
const isNativeApp = window.HotwireNative || navigator.userAgent.includes('Hotwire Native');

if (isNativeApp) {
  // Prevent viewport scaling that can affect navigation bars
  document.addEventListener('DOMContentLoaded', function() {
    // Create or update viewport meta tag for native app
    let viewport = document.querySelector('meta[name="viewport"]');
    if (viewport) {
      viewport.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover');
    }
    
    // Prevent scroll-based appearance changes
    document.body.style.overscrollBehavior = 'none';
    document.documentElement.style.overscrollBehavior = 'none';
    
    // Ensure proper safe area handling
    document.documentElement.style.setProperty('--safe-area-inset-top', 'env(safe-area-inset-top)');
    document.documentElement.style.setProperty('--safe-area-inset-bottom', 'env(safe-area-inset-bottom)');
  });
  
  // Prevent Bootstrap from interfering with native scrolling
  document.addEventListener('turbo:load', function() {
    // Disable Bootstrap's scroll spy if present
    const scrollSpyElements = document.querySelectorAll('[data-bs-spy="scroll"]');
    scrollSpyElements.forEach(el => el.removeAttribute('data-bs-spy'));
    
    // Prevent modal backdrop from interfering with navigation
    document.addEventListener('show.bs.modal', function(e) {
      setTimeout(() => {
        const backdrop = document.querySelector('.modal-backdrop');
        if (backdrop) {
          backdrop.style.zIndex = '1040';
        }
      }, 100);
    });
  });
  
  // Override any scroll event listeners that might affect appearance
  let originalAddEventListener = EventTarget.prototype.addEventListener;
  EventTarget.prototype.addEventListener = function(type, listener, options) {
    if (type === 'scroll' && (this === window || this === document)) {
      // Wrap scroll listeners to prevent navigation bar appearance changes
      const wrappedListener = function(event) {
        // Prevent the event from bubbling to native scroll handlers
        event.preventDefault = function() {};
        listener.call(this, event);
      };
      return originalAddEventListener.call(this, type, wrappedListener, options);
    }
    return originalAddEventListener.call(this, type, listener, options);
  };
}
