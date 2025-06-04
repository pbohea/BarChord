import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { message: String }

  prompt(event) {
    event.preventDefault()
    
    // Use custom message if provided, otherwise use default
    const message = this.messageValue || "You need to sign in. Go to sign in page?"
    
    if (confirm(message)) {
      window.location.href = "/users/sign_in"
    }
  }
}
