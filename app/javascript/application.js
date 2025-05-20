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
