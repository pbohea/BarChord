import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "hidden", "details", "username", "imageContainer", "bio", "verification", "submitButton"]

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
    this.updateSubmitButton()
  }

  hideDetails() {
    console.log("HIDE DETAILS CALLED")
    if (this.hasDetailsTarget) {
      this.detailsTarget.classList.add("d-none")
      console.log("Added d-none class")
    }
    if (this.hasHiddenTarget) {
      this.hiddenTarget.value = ""
    }
    // Reset verification and disable submit when hiding
    if (this.hasVerificationTarget) {
      this.verificationTarget.checked = false
    }
    this.updateSubmitButton()
  }

  toggleSubmit() {
    console.log("toggleSubmit called")
    this.updateSubmitButton()
  }

  updateSubmitButton() {
    console.log("updateSubmitButton called")
    console.log("Has submit button target:", this.hasSubmitButtonTarget)
    console.log("Has verification target:", this.hasVerificationTarget)
    
    if (this.hasSubmitButtonTarget && this.hasVerificationTarget) {
      const isChecked = this.verificationTarget.checked
      console.log("Checkbox is checked:", isChecked)
      console.log("Setting submit button disabled to:", !isChecked)
      this.submitButtonTarget.disabled = !isChecked
    } else {
      console.log("Missing targets!")
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
