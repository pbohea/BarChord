import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "hidden"]

  search() {
    const query = this.inputTarget.value.trim()

    if (query.length < 2) {
      this.resultsTarget.innerHTML = ""
      return
    }

    fetch(`/venues/search.json?query=${encodeURIComponent(query)}`)
      .then(response => response.json())
      .then(data => {
        this.resultsTarget.innerHTML = ""

        data.forEach(venue => {
          const li = document.createElement("li")
          li.textContent = venue.name
          li.classList.add("list-group-item", "list-group-item-action")
          li.dataset.action = "click->venue-autocomplete#select"
          li.dataset.id = venue.id
          this.resultsTarget.appendChild(li)
        })
      })
  }

  select(event) {
    const venueName = event.target.textContent
    const venueId = event.target.dataset.id

    this.inputTarget.value = venueName
    this.hiddenTarget.value = venueId
    this.resultsTarget.innerHTML = ""
  }
}
