import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "hidden", "details", "username", "imageContainer", "bio", "verification", "submitButton", "manualNameField"]

  connect() {
    console.log("Artist autocomplete controller connected")
    this.isSelecting = false
    
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
        // Only call updateSubmitButton if it exists (for forms with submit buttons)
        if (typeof this.updateSubmitButton === 'function') {
          this.updateSubmitButton()
        }
      })
    }
  }

  search() {
    if (this.isSelecting) {
      console.log("SKIPPING search because selecting artist")
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

  selectArtist(id, username, image, bio) {
    console.log("Selecting artist:", { id, username, image, bio })
    
    this.isSelecting = true
    
    // Update form fields
    this.inputTarget.value = username
    this.hiddenTarget.value = id
    
    // Clear dropdown
    this.resultsTarget.innerHTML = ""
    
    // Show details
    this.showDetails(username, image, bio)
    
    // Trigger change event on hidden input to notify home-search controller
    this.hiddenTarget.dispatchEvent(new Event('change', { bubbles: true }))
    
    // Use setTimeout to ensure the input event has finished processing
    setTimeout(() => {
      this.isSelecting = false
    }, 100)
  }

  showDetails(username, image, bio) {
    console.log("Showing details for:", username, image, bio)
    
    if (this.hasUsernameTarget) {
      this.usernameTarget.textContent = username
      console.log("Set username target")
    }
    
    if (this.hasImageContainerTarget) {
      // Create image element dynamically
      const placeholderSVG = 'data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22%3E%3Ccircle cx=%2250%22 cy=%2250%22 r=%2240%22 fill=%22%23ddd%22/%3E%3Ctext x=%2250%22 y=%2255%22 text-anchor=%22middle%22 font-size=%2220%22 fill=%22%23999%22%3ENo Photo%3C/text%3E%3C/svg%3E'
      
      const img = document.createElement('img')
      img.src = image || placeholderSVG
      img.alt = 'Artist photo'
      img.className = 'rounded-circle'
      img.style.width = '80px'
      img.style.height = '80px'
      img.style.objectFit = 'cover'
      
      // Clear container and add new image
      this.imageContainerTarget.innerHTML = ''
      this.imageContainerTarget.appendChild(img)
      console.log("Set image in container")
    }
    
    if (this.hasBioTarget) {
      this.bioTarget.textContent = bio || 'No bio available'
      console.log("Set bio target")
    }
    
    if (this.hasDetailsTarget) {
      this.detailsTarget.classList.remove("d-none")
      console.log("Removed d-none class")
    }

    // Reset verification checkbox and disable submit button
    if (this.hasVerificationTarget) {
      this.verificationTarget.checked = false
    }
    
    // Disable manual name field when artist is selected
    if (this.hasManualNameFieldTarget) {
      this.manualNameFieldTarget.disabled = true
      this.manualNameFieldTarget.value = '' // Clear any existing value
      this.manualNameFieldTarget.placeholder = 'Artist selected from database'
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
    
    // Re-enable manual name field when no artist is selected
    if (this.hasManualNameFieldTarget) {
      this.manualNameFieldTarget.disabled = false
      this.manualNameFieldTarget.placeholder = 'Enter artist name'
    }
    
    // Only call updateSubmitButton if it exists (for forms with submit buttons)
    if (typeof this.updateSubmitButton === 'function') {
      this.updateSubmitButton()
    }
  }

  // Legacy select method for backward compatibility
  select(event) {
    const artistName = event.target.textContent
    const artistId = event.target.dataset.id
    const artistImage = event.target.dataset.artistImage || ""
    const artistBio = event.target.dataset.artistBio || ""

    this.selectArtist(artistId, artistName, artistImage, artistBio)
  }
}
