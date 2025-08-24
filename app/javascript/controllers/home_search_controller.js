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
    this.timer = setInterval(() => this.updateState(), 300) // lightweight poll
  }

  disconnect() {
    if (this.timer) clearInterval(this.timer)
  }

  /* ------------------------------------------------- */
  /*  State machine                                    */
  /* ------------------------------------------------- */
  updateState() {
    const venueSlug  = this.hasVenueHiddenTarget  ? (this.venueHiddenTarget.value || "").trim()  : ""
    const artistSlug = this.hasArtistHiddenTarget ? (this.artistHiddenTarget.value || "").trim() : ""

    const venueSelected  = venueSlug.length > 0
    const artistSelected = artistSlug.length > 0

    // Show / hide buttons based on selection
    if (this.hasVenueButtonTarget)  this.venueButtonTarget.classList.toggle("d-none", !venueSelected)
    if (this.hasArtistButtonTarget) this.artistButtonTarget.classList.toggle("d-none", !artistSelected)

    // Show / hide clear icons (if present)
    if (this.hasVenueClearTarget && this.hasVenueInputTarget) {
      this.venueClearTarget.classList.toggle("d-none", !(this.venueInputTarget.value || "").trim())
    }
    if (this.hasArtistClearTarget && this.hasArtistInputTarget) {
      this.artistClearTarget.classList.toggle("d-none", !(this.artistInputTarget.value || "").trim())
    }

    // Grey-out the other card (defensive guards)
    if (venueSelected && this.hasArtistCardTarget && this.hasVenueCardTarget) {
      this.greyOut(this.artistCardTarget)
      this.unGrey(this.venueCardTarget)
    } else if (artistSelected && this.hasVenueCardTarget && this.hasArtistCardTarget) {
      this.greyOut(this.venueCardTarget)
      this.unGrey(this.artistCardTarget)
    } else {
      if (this.hasVenueCardTarget)  this.unGrey(this.venueCardTarget)
      if (this.hasArtistCardTarget) this.unGrey(this.artistCardTarget)
    }
  }

  /* ------------------------------------------------- */
  /*  Actions                                          */
  /* ------------------------------------------------- */
  goToVenue() {
    if (!this.hasVenueHiddenTarget) return
    const slug = (this.venueHiddenTarget.value || "").trim()
    if (slug) {
      window.location.assign(`/venues/${encodeURIComponent(slug)}`)
    }
  }

  goToArtist() {
    if (!this.hasArtistHiddenTarget) return
    const slug = (this.artistHiddenTarget.value || "").trim()
    if (slug) {
      window.location.assign(`/artists/${encodeURIComponent(slug)}`)
    }
  }

  clearVenue() {
    if (this.hasVenueInputTarget)  this.venueInputTarget.value = ""
    if (this.hasVenueHiddenTarget) {
      this.venueHiddenTarget.value = ""
      // Notify listeners (e.g., autocomplete controllers)
      this.venueHiddenTarget.dispatchEvent(new Event('change', { bubbles: true }))
    }
    // Trigger input to let autocomplete clear its dropdown/details
    if (this.hasVenueInputTarget) {
      this.venueInputTarget.dispatchEvent(new Event('input', { bubbles: true }))
    }
    this.updateState()
  }

  clearArtist() {
    if (this.hasArtistInputTarget)  this.artistInputTarget.value = ""
    if (this.hasArtistHiddenTarget) {
      this.artistHiddenTarget.value = ""
      // Notify listeners (e.g., autocomplete controllers)
      this.artistHiddenTarget.dispatchEvent(new Event('change', { bubbles: true }))
    }
    // Trigger input to let autocomplete clear its dropdown/details
    if (this.hasArtistInputTarget) {
      this.artistInputTarget.dispatchEvent(new Event('input', { bubbles: true }))
    }
    this.updateState()
  }

  /* ------------------------------------------------- */
  /*  Helpers                                          */
  /* ------------------------------------------------- */
  greyOut(card) {
    if (!card) return
    card.classList.add("opacity-50", "pointer-events-none")
    // Disable text inputs within the card but leave hidden fields alone
    card.querySelectorAll('input[type="text"], input[type="search"]').forEach(el => (el.disabled = true))
  }

  unGrey(card) {
    if (!card) return
    card.classList.remove("opacity-50", "pointer-events-none")
    card.querySelectorAll('input[type="text"], input[type="search"]').forEach(el => (el.disabled = false))
  }
}
