import { Controller } from "@hotwired/stimulus"
import $ from "jquery"
import "select2"

export default class extends Controller {
  connect() {
    $(this.element).select2({
      placeholder: "Search for an artist...",
      allowClear: true,
      width: '100%',
      ajax: {
        url: "/artists/search",
        dataType: "json",
        delay: 200,
        data: function (params) {
          return { q: params.term }
        },
        processResults: function (data) {
          return { results: data }
        },
        cache: true
      }
    })
  }
}
