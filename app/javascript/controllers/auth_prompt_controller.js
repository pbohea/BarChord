import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  prompt(event) {
    event.preventDefault()
    
    if (confirm("You need to sign in to follow artists. Go to sign in page?")) {
      window.location.href = "/users/sign_in"
    }
  }
}
