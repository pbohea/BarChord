import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "input", "results", "hidden", "details", "username", "imageContainer", 
    "bio", "verification", "submitButton", "manualNameField", "manualConfirmation"
  ]

  connect() {
    console.log("Owner artist autocomplete controller connected")
    this.isSelecting = false
    this.manualConfirmationShown = false
    
    // Set up a safe fallback for the image
    if (this.hasImageTarget) {
      this.imageTarget.onerror = () => {
        this.imageTarget.onerror = null // Prevent infinite loop
        this.imageTarget.src = 'data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22%3E%3Ccircle cx=%2250%22 cy=%2250%22 r=%2240%22 fill=%22%23ddd%22/%3E%3Ctext x=%2250%22 y=%2255%22 text-anchor=%22middle%22 font-size=%2220%22 fill=%22%23999%22%3ENo Photo%3C/text%3E%3C/svg%3E'
      }
    }
    
    // Add listener to manual name field
    if (this.hasManualNameFieldTarget) {
      this.manualNameFieldTarget.addEventListener('input', () => {
        this.handleManualNameInput()
      })
      
      this.manualNameFieldTarget.addEventListener('blur', () => {
        this.handleManualNameBlur()
      })
    }
  }

  search() {
    if (this.isSelecting) {
      console.log("SKIPPING search because selecting artist")
      return
    }

    // Don't search if manual name field has content
    if (this.hasManualNameFieldTarget && this.manualNameFieldTarget.value.trim() !== "") {
      console.log("SKIPPING search because manual name is filled")
      return
    }

    const query = this.inputTarget.value.trim()
    console.log("Search called with:", query)

    if (query.length < 2) {
      this.resultsTarget.innerHTML = ""
      this.hideDetails()
      return
    }

    fetch(`/artists/search.json?query=${encodeURIComponent(query)}`)
      .then(response => response.json())
      .then(data => {
        console.log("Got artists:", data)
        this.displayResults(data)
      })
      .catch(error => {
        console.error('Search error:', error)
      })
  }

  displayResults(artists) {
    this.resultsTarget.innerHTML = ""
    
    artists.forEach(artist => {
      const li = document.createElement("li")
      li.textContent = artist.username
      li.classList.add("list-group-item", "list-group-item-action")
      li.style.cursor = "pointer"
      
      // Gray out if manual name is filled
      if (this.hasManualNameFieldTarget && this.manualNameFieldTarget.value.trim() !== "") {
        li.classList.add("text-muted")
        li.style.pointerEvents = "none"
        li.style.opacity = "0.5"
      }
      
      // Store artist data
      li.dataset.artistId = artist.id
      li.dataset.artistUsername = artist.username
      li.dataset.artistImage = artist.image || ""
      li.dataset.artistBio = artist.bio || ""
      
      li.addEventListener('click', () => {
        this.selectArtist(artist.id, artist.username, artist.image, artist.bio)
      })
      
      this.resultsTarget.appendChild(li)
    })
  }

  handleManualNameInput() {
    const hasManualText = this.manualNameFieldTarget.value.trim() !== ""
    
    if (hasManualText) {
      // Clear database search
      this.inputTarget.value = ""
      this.resultsTarget.innerHTML = ""
      this.hideDetails()
      
      // Disable database search visually
      this.inputTarget.disabled = true
      this.inputTarget.placeholder = "Database search disabled - manual name entered"
      this.inputTarget.classList.add("bg-light", "text-muted")
      
      // Reset manual confirmation
      this.manualConfirmationShown = false
      this.hideManualConfirmation()
    } else {
      // Re-enable database search
      this.inputTarget.disabled = false
      this.inputTarget.placeholder = "Start typing..."
      this.inputTarget.classList.remove("bg-light", "text-muted")
      
      // Hide manual confirmation
      this.hideManualConfirmation()
    }
    
    this.updateSubmitButton()
  }

  handleManualNameBlur() {
    const hasManualText = this.manualNameFieldTarget.value.trim() !== ""
    
    if (hasManualText && !this.manualConfirmationShown) {
      // Show confirmation dialog after a short delay to allow for other interactions
      setTimeout(() => {
        if (this.manualNameFieldTarget.value.trim() !== "") {
          this.showManualConfirmation()
        }
      }, 200)
    }
  }

  showManualConfirmation() {
    this.manualConfirmationShown = true
    
    // Create or show the confirmation section
    let confirmationDiv = document.getElementById('manual-artist-confirmation')
    
    if (!confirmationDiv) {
      confirmationDiv = document.createElement('div')
      confirmationDiv.id = 'manual-artist-confirmation'
      confirmationDiv.className = 'border border-warning rounded p-3 bg-warning-subtle mt-3'
      confirmationDiv.innerHTML = `
        <h6 class="text-warning">⚠️ Artist Not in Database</h6>
        <p class="mb-2 small">Are you sure this artist isn't in our database? Try searching above first.</p>
        <div class="d-flex gap-2 mb-3">
          <button type="button" class="btn btn-sm btn-outline-primary" data-action="click->owner-artist-autocomplete#clearManualAndSearch">
            Let me search again
          </button>
        </div>
        <div class="form-check">
          <input class="form-check-input" type="checkbox" id="manual_artist_confirmation" name="manual_artist_confirmation" value="1" data-owner-artist-autocomplete-target="manualConfirmation">
          <label class="form-check-label small" for="manual_artist_confirmation">
            <strong>Yes, I've searched and they're not in the database</strong>
          </label>
        </div>
        <p class="text-muted small mt-2 mb-0">💡 <strong>Ask them to join BarChord!</strong> They can sign up as an artist to manage their own events.</p>
      `
      
      // Insert after the manual name field
      this.manualNameFieldTarget.parentNode.insertBefore(confirmationDiv, this.manualNameFieldTarget.nextSibling)
      
      // Add listener to the checkbox
      const checkbox = confirmationDiv.querySelector('[data-owner-artist-autocomplete-target="manualConfirmation"]')
      if (checkbox) {
        checkbox.addEventListener('change', () => {
          this.updateSubmitButton()
        })
      }
    } else {
      confirmationDiv.style.display = 'block'
    }
  }

  clearManualAndSearch() {
    // Clear manual name field
    this.manualNameFieldTarget.value = ""
    
    // Trigger input event to update UI
    this.manualNameFieldTarget.dispatchEvent(new Event('input'))
    
    // Hide confirmation
    this.hideManualConfirmation()
    
    // Focus on search field
    this.inputTarget.focus()
  }

  hideManualConfirmation() {
    const confirmationDiv = document.getElementById('manual-artist-confirmation')
    if (confirmationDiv) {
      confirmationDiv.style.display = 'none'
      // Uncheck the checkbox
      const checkbox = confirmationDiv.querySelector('input[type="checkbox"]')
      if (checkbox) {
        checkbox.checked = false
      }
    }
  }

  selectArtist(id, username, image, bio) {
    console.log("Selecting artist:", { id, username, image, bio })
    
    this.isSelecting = true
    
    // Update form fields
    this.inputTarget.value = username
    this.hiddenTarget.value = id
    
    // Clear dropdown
    this.resultsTarget.innerHTML = ""
    
    // Clear manual name field
    this.manualNameFieldTarget.value = ""
    this.hideManualConfirmation()
    
    // Show details
    this.showDetails(username, image, bio)
    
    // Use setTimeout to ensure the input event has finished processing
    setTimeout(() => {
      this.isSelecting = false
    }, 100)
  }

  showDetails(username, image, bio) {
    console.log("Showing details for:", username, image, bio)
    
    if (this.hasUsernameTarget) {
      this.usernameTarget.textContent = username
    }
    
    if (this.hasImageContainerTarget) {
      const placeholderSVG = 'data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22%3E%3Ccircle cx=%2250%22 cy=%2250%22 r=%2240%22 fill=%22%23ddd%22/%3E%3Ctext x=%2250%22 y=%2255%22 text-anchor=%22middle%22 font-size=%2220%22 fill=%22%23999%22%3ENo Photo%3C/text%3E%3C/svg%3E'
      
      const img = document.createElement('img')
      img.src = image || placeholderSVG
      img.alt = 'Artist photo'
      img.className = 'rounded-circle'
      img.style.width = '80px'
      img.style.height = '80px'
      img.style.objectFit = 'cover'
      
      this.imageContainerTarget.innerHTML = ''
      this.imageContainerTarget.appendChild(img)
    }
    
    if (this.hasBioTarget) {
      this.bioTarget.textContent = bio || 'No bio available'
    }
    
    if (this.hasDetailsTarget) {
      this.detailsTarget.classList.remove("d-none")
    }

    // Reset verification checkbox and disable submit button
    if (this.hasVerificationTarget) {
      this.verificationTarget.checked = false
    }
    
    // Disable manual name field when artist is selected from database
    this.manualNameFieldTarget.disabled = true
    this.manualNameFieldTarget.value = ""
    this.manualNameFieldTarget.placeholder = "Artist selected from database"
    this.manualNameFieldTarget.classList.add("bg-light", "text-muted")
    
    // Hide manual confirmation since we have a database artist
    this.hideManualConfirmation()
    
    this.updateSubmitButton()
  }

  hideDetails() {
    console.log("HIDE DETAILS CALLED")
    if (this.hasDetailsTarget) {
      this.detailsTarget.classList.add("d-none")
    }
    if (this.hasHiddenTarget) {
      this.hiddenTarget.value = ""
    }
    
    if (this.hasVerificationTarget) {
      this.verificationTarget.checked = false
    }
    
    // Re-enable manual name field when no artist is selected
    this.manualNameFieldTarget.disabled = false
    this.manualNameFieldTarget.placeholder = "Or enter artist name"
    this.manualNameFieldTarget.classList.remove("bg-light", "text-muted")
    
    this.updateSubmitButton()
  }

  toggleSubmit() {
    this.updateSubmitButton()
  }

  updateSubmitButton() {
    if (!this.hasSubmitButtonTarget) return
    
    const hasSelectedArtist = this.hiddenTarget.value !== ""
    const hasManualName = this.manualNameFieldTarget.value.trim() !== ""
    const isVerified = this.hasVerificationTarget ? this.verificationTarget.checked : true
    
    // Check manual confirmation
    const manualConfirmationDiv = document.getElementById('manual-artist-confirmation')
    const isManualConfirmed = manualConfirmationDiv ? 
      manualConfirmationDiv.querySelector('input[type="checkbox"]')?.checked || false : 
      true
    
    // Enable submit if either:
    // 1. Artist is selected from database AND verified
    // 2. Manual name is entered AND confirmed
    const canSubmit = (hasSelectedArtist && isVerified) || (hasManualName && isManualConfirmed)
    
    this.submitButtonTarget.disabled = !canSubmit
  }
}
