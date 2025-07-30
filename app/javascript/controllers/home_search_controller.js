import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    // VENUE
    "venueHidden", "venueButton", "venueCard", "venueInput", "venueClear",
    // ARTIST
    "artistHidden", "artistButton", "artistCard", "artistInput", "artistClear"
  ]

  /* ------------------------------------------------- */
  /*  Life-cycle                                       */
  /* ------------------------------------------------- */
  connect() {
    console.log("✅ home-search connected")
    this.updateState()
    this.timer = setInterval(() => this.updateState(), 300)  // lightweight poll
  }

  disconnect() {
    clearInterval(this.timer)
  }

  /* ------------------------------------------------- */
  /*  State machine                                    */
  /* ------------------------------------------------- */
  updateState() {
    const venueSelected  = this.venueHiddenTarget.value !== ""
    const artistSelected = this.artistHiddenTarget.value !== ""

    // Show / hide buttons based on selection
    this.venueButtonTarget.classList.toggle("d-none", !venueSelected)
    this.artistButtonTarget.classList.toggle("d-none", !artistSelected)

    // Show / hide clear icons (if present)
    if (this.hasVenueClearTarget)  this.venueClearTarget.classList.toggle("d-none", !this.venueInputTarget.value)
    if (this.hasArtistClearTarget) this.artistClearTarget.classList.toggle("d-none", !this.artistInputTarget.value)

    // Grey-out other card
    if (venueSelected) {
      this.greyOut(this.artistCardTarget)
      this.unGrey(this.venueCardTarget)
    } else if (artistSelected) {
      this.greyOut(this.venueCardTarget)
      this.unGrey(this.artistCardTarget)
    } else {
      this.unGrey(this.venueCardTarget)
      this.unGrey(this.artistCardTarget)
    }
  }

  /* ------------------------------------------------- */
  /*  Actions                                          */
  /* ------------------------------------------------- */
  goToVenue() { 
    if (this.venueHiddenTarget.value) {
      window.location.href = `/venues/${this.venueHiddenTarget.value}`
    }
  }
  
  goToArtist() { 
    if (this.artistHiddenTarget.value) {
      window.location.href = `/artists/${this.artistHiddenTarget.value}`
    }
  }

  clearVenue() {
    this.venueInputTarget.value  = ""
    this.venueHiddenTarget.value = ""
    
    // Trigger input event to clear autocomplete results and hide details
    this.venueInputTarget.dispatchEvent(new Event('input', { bubbles: true }))
    
    this.updateState()
  }

  clearArtist() {
    this.artistInputTarget.value  = ""
    this.artistHiddenTarget.value = ""
    
    // Trigger input event to clear autocomplete results and hide details
    this.artistInputTarget.dispatchEvent(new Event('input', { bubbles: true }))
    
    this.updateState()
  }

  /* ------------------------------------------------- */
  /*  Helpers                                          */
  /* ------------------------------------------------- */
  greyOut(card) {
    card.classList.add("opacity-50", "pointer-events-none")
    card.querySelectorAll("input").forEach(el => (el.disabled = true))
  }

  unGrey(card) {
    card.classList.remove("opacity-50", "pointer-events-none")
    card.querySelectorAll("input").forEach(el => (el.disabled = false))
  }
}
