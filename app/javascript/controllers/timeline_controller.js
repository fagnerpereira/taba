import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "form", "timeline" ]

  connect() {
    console.log("Timeline controller connected")
  }

  success(event) {
    const [data, status, xhr] = event.detail
    // This is handled by Turbo Streams usually, but if we want manual control:
    // this.formTarget.reset()
  }

  error(event) {
    console.error("Error posting message", event.detail)
  }
}
