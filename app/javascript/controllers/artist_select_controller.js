import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Wait until jQuery + Select2 are available
    const interval = setInterval(() => {
      if (window.$ && typeof window.$.fn.select2 === "function") {
        clearInterval(interval)

        console.log("✅ artist-select connected, Select2 ready")
        window.$(this.element).select2({
          placeholder: "Search for an artist...",
          allowClear: true,
          width: '100%',
          ajax: {
            url: "/artists/search",
            dataType: "json",
            delay: 200,
            data: params => ({ q: params.term }),
            processResults: data => ({ results: data }),
            cache: true
          }
        })
      }
    }, 50)
  }
}
