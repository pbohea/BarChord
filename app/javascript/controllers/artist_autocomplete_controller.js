import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "hidden"]

  search() {
    const query = this.inputTarget.value.trim()

    if (query.length < 2) {
      this.resultsTarget.innerHTML = ""
      return
    }

    fetch(`/artists/search.json?query=${encodeURIComponent(query)}`)
      .then(response => response.json())
      .then(data => {
        this.resultsTarget.innerHTML = ""

        data.forEach(artist => {
          const li = document.createElement("li")
          li.textContent = artist.username
          li.classList.add("list-group-item", "list-group-item-action")
          li.dataset.action = "click->artist-autocomplete#select"
          li.dataset.id = artist.id
          this.resultsTarget.appendChild(li)
        })
      })
  }

  select(event) {
    const artistName = event.target.textContent
    const artistId = event.target.dataset.id

    this.inputTarget.value = artistName
    this.hiddenTarget.value = artistId
    this.resultsTarget.innerHTML = ""
  }
}
