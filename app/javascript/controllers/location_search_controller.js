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
    // Restore previous search from localStorage
    this.restorePreviousSearch()
  }

  useCurrentLocation() {
    if (!navigator.geolocation) {
      alert("Geolocation is not supported by this browser.")
      return
    }

    // Show loading state
    const button = event.target
    const originalText = button.innerHTML
    button.innerHTML = '<i class="spinner-border spinner-border-sm"></i> Getting location...'
    button.disabled = true

    navigator.geolocation.getCurrentPosition(
      (position) => {
        const lat = position.coords.latitude
        const lng = position.coords.longitude
        
        // Set hidden form fields
        this.latInputTarget.value = lat
        this.lngInputTarget.value = lng
        
        // Clear address field since we're using coordinates
        this.addressInputTarget.value = ""
        
        // Save to localStorage
        this.saveSearchToStorage({ lat, lng, address: "", radius: this.currentRadiusValue })
        
        // Submit the form
        this.element.requestSubmit()
      },
      (error) => {
        console.error("Error getting location:", error)
        let message = "Unable to get your location. "
        
        switch(error.code) {
          case error.PERMISSION_DENIED:
            message += "Please allow location access and try again."
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
        
        alert(message)
        
        // Restore button
        button.innerHTML = originalText
        button.disabled = false
      },
      {
        enableHighAccuracy: true,
        timeout: 10000,
        maximumAge: 300000 // 5 minutes
      }
    )
  }

  restorePreviousSearch() {
    // Don't restore if we already have current search params
    if (this.currentLatValue || this.currentAddressValue) {
      return
    }

    try {
      const saved = localStorage.getItem('lastEventSearch')
      if (saved) {
        const searchData = JSON.parse(saved)
        
        if (searchData.address) {
          this.addressInputTarget.value = searchData.address
        }
        
        if (searchData.lat && searchData.lng) {
          this.latInputTarget.value = searchData.lat
          this.lngInputTarget.value = searchData.lng
        }
        
        // Set radius if saved
        const radiusSelect = this.element.querySelector('select[name="radius"]')
        if (radiusSelect && searchData.radius) {
          radiusSelect.value = searchData.radius
        }
      }
    } catch (error) {
      console.error("Error restoring search:", error)
    }
  }

  saveSearchToStorage(searchData) {
    try {
      localStorage.setItem('lastEventSearch', JSON.stringify(searchData))
    } catch (error) {
      console.error("Error saving search:", error)
    }
  }

  // Save search when form is submitted normally
  disconnect() {
    const formData = new FormData(this.element)
    const searchData = {
      address: formData.get('address') || "",
      lat: formData.get('lat') || "",
      lng: formData.get('lng') || "",
      radius: formData.get('radius') || 5
    }
    
    this.saveSearchToStorage(searchData)
  }
}
