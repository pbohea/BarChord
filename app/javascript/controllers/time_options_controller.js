// app/javascript/controllers/time_options_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["venue", "date", "startTime", "endTime"]

  connect() {
    // Initialize time options if venue and date are already selected
    this.updateStartTimes()
  }

  // Called when venue or date changes
  updateStartTimes() {
    const venueId = this.venueTarget.value
    const selectedDate = this.dateTarget.value
    
    if (venueId && selectedDate) {
      this.fetchStartTimes(venueId, selectedDate)
    } else {
      this.clearTimeOptions()
    }
  }

  // Called when start time changes
  updateEndTimes() {
    const venueId = this.venueTarget.value
    const selectedDate = this.dateTarget.value
    const selectedStartTime = this.startTimeTarget.value
    
    if (venueId && selectedDate && selectedStartTime) {
      this.fetchEndTimes(venueId, selectedDate, selectedStartTime)
    } else {
      this.clearEndTimeOptions()
    }
  }

  async fetchStartTimes(venueId, selectedDate) {
    try {
      const response = await fetch(`/events/time_options_ajax?venue_id=${venueId}&date=${selectedDate}`, {
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        }
      })
      
      if (response.ok) {
        const data = await response.json()
        this.populateStartTimes(data.start_times)
        this.clearEndTimeOptions() // Clear end times when start times change
      }
    } catch (error) {
      console.error('Error fetching start time options:', error)
    }
  }

  async fetchEndTimes(venueId, selectedDate, selectedStartTime) {
    try {
      const response = await fetch(`/events/end_time_options_ajax?venue_id=${venueId}&date=${selectedDate}&start_time=${selectedStartTime}`, {
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        }
      })
      
      if (response.ok) {
        const data = await response.json()
        this.populateEndTimes(data.end_times)
      }
    } catch (error) {
      console.error('Error fetching end time options:', error)
    }
  }

  populateStartTimes(times) {
    this.startTimeTarget.innerHTML = '<option value="">Select start time</option>'
    times.forEach(([display, value]) => {
      const option = new Option(display, value)
      this.startTimeTarget.add(option)
    })
  }

  populateEndTimes(times) {
    this.endTimeTarget.innerHTML = '<option value="">Select end time</option>'
    times.forEach(([display, value]) => {
      const option = new Option(display, value)
      this.endTimeTarget.add(option)
    })
  }

  clearTimeOptions() {
    this.clearStartTimeOptions()
    this.clearEndTimeOptions()
  }

  clearStartTimeOptions() {
    this.startTimeTarget.innerHTML = '<option value="">Select start time</option>'
  }

  clearEndTimeOptions() {
    this.endTimeTarget.innerHTML = '<option value="">Select end time</option>'
  }
}
