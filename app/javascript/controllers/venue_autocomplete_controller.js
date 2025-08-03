import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "hidden", "details", "name", "address", "verification", "submitButton"]

  connect() {
    console.log("Venue autocomplete controller connected")
    this.isSelecting = false
  }

  search() {
    if (this.isSelecting) {
      console.log("SKIPPING search because selecting venue")
      return
    }
    
    const query = this.inputTarget.value.trim()
    console.log("Search called with:", query)

    if (query.length < 2) {
      this.resultsTarget.innerHTML = ""
      return
    }

    fetch(`/venues/search?query=${encodeURIComponent(query)}`)
      .then(response => response.json())
      .then(data => {
        console.log("Got venues:", data)
        this.displayResults(data)
      })
      .catch(error => {
        console.error('Search error:', error)
      })
  }

  displayResults(venues) {
    this.resultsTarget.innerHTML = ""
    
    venues.forEach(venue => {
      const li = document.createElement("li")
      li.textContent = venue.name
      li.classList.add("list-group-item", "list-group-item-action")
      li.style.cursor = "pointer"
      
      // Store venue data
      li.dataset.venueId = venue.id
      li.dataset.venueName = venue.name
      li.dataset.venueAddress = this.formatAddress(venue)
      
      li.addEventListener('click', () => {
        this.selectVenue(venue.id, venue.name, this.formatAddress(venue))
      })
      
      this.resultsTarget.appendChild(li)
    })
  }

  selectVenue(id, name, address) {
    console.log("Selecting venue:", { id, name, address })
    
    this.isSelecting = true
    
    // Update form fields
    this.inputTarget.value = name
    this.hiddenTarget.value = id
    
    // Clear dropdown
    this.resultsTarget.innerHTML = ""
    
    // Show details
    this.showDetails(name, address)
    
    // Trigger change event on hidden input to notify home-search controller
    this.hiddenTarget.dispatchEvent(new Event('change', { bubbles: true }))
    
    // Use setTimeout to ensure the input event has finished processing
    setTimeout(() => {
      this.isSelecting = false
    }, 100)
  }

  showDetails(name, address) {
    console.log("Showing details for:", name, address)
    
    if (this.hasNameTarget) {
      this.nameTarget.textContent = name
      console.log("Set name target")
    }
    
    if (this.hasAddressTarget) {
      this.addressTarget.textContent = address
      console.log("Set address target")
    }
    
    if (this.hasDetailsTarget) {
      this.detailsTarget.classList.remove("d-none")
      console.log("Removed d-none class")
    }

    // Reset verification checkbox and disable submit button
    if (this.hasVerificationTarget) {
      this.verificationTarget.checked = false
    }
    
    // Only call updateSubmitButton if it exists (for forms with submit buttons)
    if (typeof this.updateSubmitButton === 'function') {
      this.updateSubmitButton()
    }
  }

  hideDetails() {
    console.log("HIDE DETAILS CALLED")
    if (this.hasDetailsTarget) {
      this.detailsTarget.classList.add("d-none")
      console.log("Added d-none class")
    }
    if (this.hasHiddenTarget) {
      this.hiddenTarget.value = ""
      // Trigger change event to notify home-search controller
      this.hiddenTarget.dispatchEvent(new Event('change', { bubbles: true }))
    }
    // Reset verification and disable submit when hiding
    if (this.hasVerificationTarget) {
      this.verificationTarget.checked = false
    }
    
    // Only call updateSubmitButton if it exists (for forms with submit buttons)
    if (typeof this.updateSubmitButton === 'function') {
      this.updateSubmitButton()
    }
  }

  formatAddress(venue) {
    const parts = [venue.street_address, venue.city, venue.state, venue.zip_code].filter(Boolean)
    return parts.join(", ")
  }
  toggleSubmit() {
  // Only update submit button if it exists (for forms that have one)
  if (this.hasSubmitButtonTarget && this.hasVerificationTarget && this.hasHiddenTarget) {
    const venueSelected = this.hiddenTarget.value !== ""
    const verified = this.verificationTarget.checked
    this.submitButtonTarget.disabled = !(venueSelected && verified)
  }
}
}
