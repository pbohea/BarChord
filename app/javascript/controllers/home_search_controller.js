import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "venueHidden", "venueButton", "venueCard",
    "artistHidden", "artistButton", "artistCard"
  ]

  connect() {
    console.log("✅ home-search connected")
    this.updateState()                // initial state
    // small polling loop — lightweight, stops on disconnect
    this.timer = setInterval(() => this.updateState(), 300)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  updateState() {
    const vSelected = this.venueHiddenTarget.value !== ""
    const aSelected = this.artistHiddenTarget.value !== ""

    this.venueButtonTarget.disabled  = !vSelected
    this.artistButtonTarget.disabled = !aSelected

    if (vSelected) {
      this.greyOut(this.artistCardTarget)
      this.unGrey(this.venueCardTarget)
    } else if (aSelected) {
      this.greyOut(this.venueCardTarget)
      this.unGrey(this.artistCardTarget)
    } else {
      this.unGrey(this.venueCardTarget)
      this.unGrey(this.artistCardTarget)
    }
  }

  // “Go” buttons
  goToVenue()  { window.location.href = `/venues/${this.venueHiddenTarget.value}` }
  goToArtist() { window.location.href = `/artists/${this.artistHiddenTarget.value}` }

  /* helpers */
  greyOut(card) {
    card.classList.add("opacity-50", "pointer-events-none")
    card.querySelectorAll("input").forEach(el => el.disabled = true)
  }
  unGrey(card) {
    card.classList.remove("opacity-50", "pointer-events-none")
    card.querySelectorAll("input").forEach(el => el.disabled = false)
  }
}
