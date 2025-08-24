import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "input",
    "results",
    "hidden",
    "details",
    "username",
    "imageContainer",
    "bio",
    "verification",
    "submitButton",
    "manualNameField"
  ]

  connect() {
    console.log("Artist autocomplete controller connected")
    this.isSelecting = false

    // Keep manual name field wired to submit button state (if present)
    if (this.hasManualNameFieldTarget) {
      this.manualNameFieldTarget.addEventListener('input', () => {
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

      // Store artist data (slug-first)
      li.dataset.artistSlug = artist.slug || ""
      li.dataset.artistUsername = artist.username || ""
      li.dataset.artistImage = artist.image || ""
      li.dataset.artistBio = artist.bio || ""

      li.addEventListener('click', () => {
        this.selectArtist(
          li.dataset.artistSlug,
          li.dataset.artistUsername,
          li.dataset.artistImage,
          li.dataset.artistBio
        )
      })

      this.resultsTarget.appendChild(li)
    })
  }

  /**
   * Select an artist (slug-first API)
   * @param {string} slug
   * @param {string} username
   * @param {string} image
   * @param {string} bio
   */
  selectArtist(slug, username, image, bio) {
    console.log("Selecting artist:", { slug, username, image, bio })

    this.isSelecting = true

    // Update form fields
    this.inputTarget.value = username
    this.hiddenTarget.value = slug  // 🔑 store the SLUG here

    // Clear dropdown
    this.resultsTarget.innerHTML = ""

    // Show details
    this.showDetails(username, image, bio)

    // Notify any listening controllers (e.g., home-search)
    this.hiddenTarget.dispatchEvent(new Event('change', { bubbles: true }))

    // Allow new searches after UI settles
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

    if (this.hasVerificationTarget) {
      this.verificationTarget.checked = false
    }

    if (this.hasManualNameFieldTarget) {
      this.manualNameFieldTarget.disabled = true
      this.manualNameFieldTarget.value = ''
      this.manualNameFieldTarget.placeholder = 'Artist selected from database'
    }

    if (typeof this.updateSubmitButton === 'function') {
      this.updateSubmitButton()
    }
  }

  hideDetails() {
    console.log("HIDE DETAILS CALLED")

    if (this.hasDetailsTarget) {
      this.detailsTarget.classList.add("d-none")
    }

    if (this.hasHiddenTarget) {
      this.hiddenTarget.value = ""  // clear slug
      this.hiddenTarget.dispatchEvent(new Event('change', { bubbles: true }))
    }

    if (this.hasVerificationTarget) {
      this.verificationTarget.checked = false
    }

    if (this.hasManualNameFieldTarget) {
      this.manualNameFieldTarget.disabled = false
      this.manualNameFieldTarget.placeholder = 'Enter artist name'
    }

    if (typeof this.updateSubmitButton === 'function') {
      this.updateSubmitButton()
    }
  }

  /**
   * Legacy method kept for backward compatibility with older markup
   * that used data attributes on the clicked element.
   * Now it expects data-artist-slug, -artist-username, -artist-image, -artist-bio.
   */
  select(event) {
    const { artistSlug, artistUsername, artistImage, artistBio } = event.target.dataset
    if (!artistSlug) {
      console.warn("Legacy select called without data-artist-slug")
      return
    }
    this.selectArtist(artistSlug, artistUsername, artistImage || "", artistBio || "")
  }
}
