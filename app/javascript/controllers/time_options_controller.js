// app/javascript/controllers/time_options_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["venue", "date", "startTime", "endTime"]

  connect() { this.updateStartTimes() }

  venueChanged() {
    this.updateDateOptions()
    this.clearTimeOptions()
  }

  updateStartTimes() {
    const venueSlug = (this.venueTarget?.value || "").trim()
    const selectedDate = (this.dateTarget?.value || "").trim()
    if (venueSlug && selectedDate) {
      this.fetchStartTimes(venueSlug, selectedDate)
    } else {
      this.clearTimeOptions()
    }
  }

  updateEndTimes() {
    const venueSlug = (this.venueTarget?.value || "").trim()
    const selectedDate = (this.dateTarget?.value || "").trim()
    const selectedStartTime = (this.startTimeTarget?.value || "").trim()
    if (venueSlug && selectedDate && selectedStartTime) {
      this.fetchEndTimes(venueSlug, selectedDate, selectedStartTime)
    } else {
      this.clearEndTimeOptions()
    }
  }

  async updateDateOptions() {
    const venueSlug = (this.venueTarget?.value || "").trim()
    if (!venueSlug) return
    try {
      const url = `/events/date_options_ajax?venue_slug=${encodeURIComponent(venueSlug)}`
      const res = await fetch(url, { headers: { Accept: "application/json", "X-Requested-With": "XMLHttpRequest" } })
      if (res.ok) {
        const data = await res.json()
        this.populateDateOptions(data.date_options)
      }
    } catch (e) { console.error("Error fetching date options:", e) }
  }

  populateDateOptions(dates) {
    const cur = this.dateTarget.value
    this.dateTarget.innerHTML = '<option value="">Select date</option>'
    dates.forEach(([display, value]) => this.dateTarget.add(new Option(display, value)))
    this.clearTimeOptions()
  }

  async fetchStartTimes(venueSlug, selectedDate) {
    try {
      const url = `/events/time_options_ajax?venue_slug=${encodeURIComponent(venueSlug)}&date=${encodeURIComponent(selectedDate)}`
      const res = await fetch(url, { headers: { Accept: "application/json", "X-Requested-With": "XMLHttpRequest" } })
      if (res.ok) {
        const data = await res.json()
        this.populateStartTimes(data.start_times)
        this.clearEndTimeOptions()
      }
    } catch (e) { console.error("Error fetching start time options:", e) }
  }

  async fetchEndTimes(venueSlug, selectedDate, selectedStartTime) {
    try {
      const url = `/events/end_time_options_ajax?venue_slug=${encodeURIComponent(venueSlug)}&date=${encodeURIComponent(selectedDate)}&start_time=${encodeURIComponent(selectedStartTime)}`
      const res = await fetch(url, { headers: { Accept: "application/json", "X-Requested-With": "XMLHttpRequest" } })
      if (res.ok) {
        const data = await res.json()
        this.populateEndTimes(data.end_times)
      }
    } catch (e) { console.error("Error fetching end time options:", e) }
  }

  populateStartTimes(times) {
    this.startTimeTarget.innerHTML = '<option value="">Select start time</option>'
    times.forEach(([display, value]) => this.startTimeTarget.add(new Option(display, value)))
  }

  populateEndTimes(times) {
    this.endTimeTarget.innerHTML = '<option value="">Select end time</option>'
    times.forEach(([display, value]) => this.endTimeTarget.add(new Option(display, value)))
  }

  clearTimeOptions() { this.clearStartTimeOptions(); this.clearEndTimeOptions() }
  clearStartTimeOptions() { this.startTimeTarget.innerHTML = '<option value="">Select start time</option>' }
  clearEndTimeOptions() { this.endTimeTarget.innerHTML = '<option value="">Select end time</option>' }
}
