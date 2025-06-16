import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["addressInput", "latInput", "lngInput"]
  static values = {
    currentLat: Number,
    currentLng: Number,
    currentAddress: String,
    currentRadius: Number
  }

  connect() {
    console.log("=== LOCATION SEARCH CONTROLLER v2.0 LOADED ===")
    console.log("Location search controller connected")
    console.log("Controller element:", this.element)
    console.log("Controller element tagName:", this.element.tagName)
    console.log("Has targets:", {
      address: this.hasAddressInputTarget,
      lat: this.hasLatInputTarget,
      lng: this.hasLngInputTarget
    })

    // If we have current coordinates, populate the hidden fields
    if (this.currentLatValue && this.currentLngValue) {
      this.latInputTarget.value = this.currentLatValue
      this.lngInputTarget.value = this.currentLngValue
    }

    // Clear coordinates when user types in address field
    this.addressInputTarget.addEventListener('input', () => {
      console.log("Address input changed, clearing coordinates")
      this.latInputTarget.value = ""
      this.lngInputTarget.value = ""
    })
  }

  useCurrentLocation(event) {
    console.log("Use current location clicked")
    const button = event.target

    // Check if geolocation is supported
    if (!navigator.geolocation) {
      console.error("Geolocation is not supported by this browser")
      alert("Geolocation is not supported by your browser")
      return
    }

    // Update button state
    const originalText = button.innerHTML
    button.innerHTML = '<i class="spinner-border spinner-border-sm me-1"></i> Getting location...'
    button.disabled = true

    const resetButton = () => {
      button.innerHTML = originalText
      button.disabled = false
    }

    // Set a timeout to prevent infinite loading
    const timeoutId = setTimeout(() => {
      console.error("Geolocation timeout")
      resetButton()
      alert("Location request timed out. Please try again or enter an address manually.")
    }, 10000) // 10 second timeout

    const options = {
      enableHighAccuracy: true,
      timeout: 8000, // 8 second timeout for the actual geolocation
      maximumAge: 300000 // Accept cached position up to 5 minutes old
    }

    navigator.geolocation.getCurrentPosition(
      (position) => {
        console.log("Geolocation success:", position)
        clearTimeout(timeoutId)

        const lat = position.coords.latitude
        const lng = position.coords.longitude

        console.log(`Got coordinates: ${lat}, ${lng}`)

        // Update hidden fields
        this.latInputTarget.value = lat
        this.lngInputTarget.value = lng

        // Clear address field since we're using coordinates
        this.addressInputTarget.value = ""

        // Try to reverse geocode to show user-friendly address
        this.reverseGeocode(lat, lng)
          .then(address => {
            if (address) {
              this.addressInputTarget.value = address
              console.log("Reverse geocoded to:", address)
            }
          })
          .catch(error => {
            console.warn("Reverse geocoding failed:", error)
            this.addressInputTarget.value = `${lat.toFixed(4)}, ${lng.toFixed(4)}`
          })
          .finally(() => {
            resetButton()
            this.submitForm()
          })
      },
      (error) => {
        console.error("Geolocation error:", error)
        clearTimeout(timeoutId)
        resetButton()

        let message = "Unable to get your location. "
        switch (error.code) {
          case error.PERMISSION_DENIED:
            message += "Location access was denied."
            break
          case error.POSITION_UNAVAILABLE:
            message += "Location information is unavailable."
            break
          case error.TIMEOUT:
            message += "Location request timed out."
            break
          default:
            message += "An unknown error occurred."
            break
        }

        alert(message + " Please enter an address manually.")
      },
      options
    )
  }

  submitForm() {
    console.log("=== SUBMIT FORM DEBUG ===")
    console.log("Auto-submitting form with location data")
    console.log("Form element:", this.element)
    console.log("Form tagName:", this.element.tagName)
    console.log("Form action:", this.element.action)
    console.log("Form method:", this.element.method)

    // Check if form has the required data
    console.log("Form data check:")
    console.log("- lat input value:", this.latInputTarget.value)
    console.log("- lng input value:", this.lngInputTarget.value)
    console.log("- address input value:", this.addressInputTarget.value)

    // Since this.element IS the form, submit it directly
    try {
      console.log("Trying requestSubmit()...")
      this.element.requestSubmit()
      console.log("requestSubmit() called successfully")
    } catch (error) {
      console.error("requestSubmit() failed:", error)
      console.log("Trying regular submit()...")
      try {
        this.element.submit()
        console.log("submit() called successfully")
      } catch (submitError) {
        console.error("submit() also failed:", submitError)

        // Last resort: find and click the submit button
        console.log("Trying to click submit button...")
        const submitButton = this.element.querySelector('input[type="submit"]')
        if (submitButton) {
          console.log("Found submit button:", submitButton)
          submitButton.click()
          console.log("Submit button clicked")
        } else {
          console.error("No submit button found!")
        }
      }
    }
    console.log("=== END SUBMIT DEBUG ===")
  }

  async reverseGeocode(lat, lng) {
    try {
      // Use a simple reverse geocoding service
      const response = await fetch(`https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=${lat}&longitude=${lng}&localityLanguage=en`)

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      const data = await response.json()

      // Build a nice address string
      const parts = []
      if (data.locality) parts.push(data.locality)
      if (data.principalSubdivision) parts.push(data.principalSubdivision)
      if (data.postcode) parts.push(data.postcode)

      return parts.length > 0 ? parts.join(", ") : null

    } catch (error) {
      console.error("Reverse geocoding failed:", error)
      return null
    }
  }
  autoSubmit() {
    // Submit the form automatically when dropdowns change
    this.element.requestSubmit()
  }
}
