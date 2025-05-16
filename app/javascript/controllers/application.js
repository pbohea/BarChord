import { Application } from "@hotwired/stimulus"

const application = Application.start()

application.debug = false
window.Stimulus   = application

export { application }

document.addEventListener("turbo:frame-render", (event) => {
  const frame = event.target;
  if (frame.id && frame.id.startsWith("follow_button_")) {
    const btn = frame.querySelector("form button");
    if (btn) {
      btn.classList.add("btn-follow-animate");
      setTimeout(() => btn.classList.remove("btn-follow-animate"), 200);
    }
  }
});
