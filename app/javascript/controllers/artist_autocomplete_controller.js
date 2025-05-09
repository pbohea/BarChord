import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "hidden"]

  timeout = null

  search() {
    clearTimeout(this.timeout)

    const query = this.inputTarget.value.trim()
    if (query.length < 2) {
      this.resultsTarget.innerHTML = ""
      return
    }

    this.timeout = setTimeout(() => {
      fetch(`/artists/search?q=${encodeURIComponent(query)}`)
        .then(response => response.json())
        .then(data => {
          this.resultsTarget.innerHTML = ""

          data.forEach(artist => {
            const li = document.createElement("li")
            li.className = "list-group-item list-group-item-action"
            li.textContent = artist.text
            li.dataset.artistId = artist.id
            li.addEventListener("click", () => this.select(artist))
            this.resultsTarget.appendChild(li)
          })
        })
    }, 250)
  }

  select(artist) {
    this.inputTarget.value = artist.text
    this.hiddenTarget.value = artist.id
    this.resultsTarget.innerHTML = ""
  }
}
