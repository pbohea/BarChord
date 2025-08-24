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

    // Are we on the claim page?
    const isClaimPage = window.location.pathname.includes('/claim')

    venues.forEach(venue => {
      const li = document.createElement("li")
      li.textContent = venue.name
      li.classList.add("list-group-item", "list-group-item-action")
      li.style.cursor = "pointer"

      // Store venue data with SLUG (not ID)
      li.dataset.venueSlug = venue.slug
      li.dataset.venueName = venue.name
      li.dataset.venueAddress = this.formatAddress(venue)

      li.addEventListener('click', () => {
        const slug = venue.slug
        const name = venue.name
        const address = this.formatAddress(venue)

        if (isClaimPage) {
          this.selectVenueForClaim(slug, name, address)
        } else {
          this.selectVenue(slug, name, address)
        }
      })

      this.resultsTarget.appendChild(li)
    })
  }

  // Selection for normal forms (uses slug)
  selectVenue(slug, name, address) {
    console.log("Selecting venue:", { slug, name, address })
    this.isSelecting = true

    // Update form fields
    this.inputTarget.value = name
    this.hiddenTarget.value = slug  // store the slug as the hidden field's value

    // Clear dropdown
    this.resultsTarget.innerHTML = ""

    // Show details
    this.showDetails(name, address)

    // Notify other controllers (e.g., time-options) that slug changed
    this.hiddenTarget.dispatchEvent(new Event('change', { bubbles: true }))

    // Allow search again
    setTimeout(() => {
      this.isSelecting = false
    }, 100)
  }

  // Selection logic for claim page (checks ownership by slug)
  selectVenueForClaim(slug, name, address) {
    console.log("Selecting venue for claim (slug):", { slug, name, address })
    this.isSelecting = true

    // Check ownership via slug-based route
    fetch(`/venues/${encodeURIComponent(slug)}/check_ownership`)
      .then(response => response.json())
      .then(data => {
        console.log("Ownership check response:", data)
        if (data.has_owner) {
          this.showOwnershipAlert()
          // Clear selection after showing alert
          setTimeout(() => {
            this.clearSelection()
          }, 100)
        } else {
          // Proceed with normal selection
          this.selectVenue(slug, name, address)
          return
        }
      })
      .catch(error => {
        console.error('Ownership check error (failing open):', error)
        // On error, proceed with selection
        this.selectVenue(slug, name, address)
      })
      .finally(() => {
        setTimeout(() => {
          this.isSelecting = false
        }, 200)
      })
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

    // Only call updateSubmitButton if it exists
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
      // Notify others that slug cleared
      this.hiddenTarget.dispatchEvent(new Event('change', { bubbles: true }))
    }
    if (this.hasVerificationTarget) {
      this.verificationTarget.checked = false
    }
    if (typeof this.updateSubmitButton === 'function') {
      this.updateSubmitButton()
    }
  }

  formatAddress(venue) {
    const parts = [venue.street_address, venue.city, venue.state, venue.zip_code].filter(Boolean)
    return parts.join(", ")
  }

  toggleSubmit() {
    if (this.hasSubmitButtonTarget && this.hasVerificationTarget && this.hasHiddenTarget) {
      const venueSelected = this.hiddenTarget.value !== ""   // slug present?
      const verified = this.verificationTarget.checked
      this.submitButtonTarget.disabled = !(venueSelected && verified)
    }
  }

  showOwnershipAlert() {
    console.log("showOwnershipAlert called")

    // Remove any existing alerts first
    const existingAlert = document.querySelector('.venue-ownership-alert')
    if (existingAlert) existingAlert.remove()

    const alertHtml = `
      <div class="venue-ownership-alert" style="
        position: fixed;
        top: 80px;
        left: 50%;
        transform: translateX(-50%);
        z-index: 9999;
        background-color: #fff3cd;
        border: 2px solid #ffc107;
        border-radius: 8px;
        padding: 15px 20px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.3);
        max-width: 500px;
        width: 90%;
      ">
        <div style="display: flex; justify-content: space-between; align-items: flex-start;">
          <div>
            <strong style="color: #856404;">Venue Unavailable</strong><br>
            <span style="color: #856404;">This venue already has an owner and cannot be claimed. Please contact 
            <a href="mailto:admin@barchord.co" style="color: #856404; text-decoration: underline;">admin@barchord.co</a> 
            to dispute ownership.</span>
          </div>
          <button onclick="this.parentElement.parentElement.remove()" style="
            background: none;
            border: none;
            font-size: 20px;
            cursor: pointer;
            color: #856404;
            margin-left: 10px;
          ">&times;</button>
        </div>
      </div>
    `
    document.body.insertAdjacentHTML('afterbegin', alertHtml)
    console.log("Alert inserted into body")
  }

  clearSelection() {
    this.inputTarget.value = ""
    this.resultsTarget.innerHTML = ""
    this.hiddenTarget.value = ""

    if (this.hasDetailsTarget) {
      this.detailsTarget.classList.add("d-none")
    }

    this.hiddenTarget.dispatchEvent(new Event('change', { bubbles: true }))
  }
}
