import { Controller } from "@hotwired/stimulus"
import Cropper from "cropperjs"

export default class extends Controller {
  static targets = ["input", "preview"]

  connect() {
    this.cropper = null
  }

  previewImage(event) {
  const file = event.target.files[0]
  if (!file || !file.type.startsWith("image/")) return

  const reader = new FileReader()
  reader.onload = () => {
    this.previewTarget.src = reader.result
    this.previewTarget.classList.remove("d-none")

    const initializeCropper = () => {
      if (this.cropper && typeof this.cropper.destroy === "function") {
        this.cropper.destroy()
      }

      this.cropper = new Cropper(this.previewTarget, {
        aspectRatio: 1,
        viewMode: 1,
        autoCropArea: 1,
        responsive: true,
      })
    }

    // If image is already cached, onload won't fire — handle that
    if (this.previewTarget.complete && this.previewTarget.naturalWidth !== 0) {
      initializeCropper()
    } else {
      this.previewTarget.onload = initializeCropper
    }
  }

  reader.readAsDataURL(file)
}

  cropAndReplace() {
  if (!this.cropper || typeof this.cropper.getCroppedCanvas !== "function") {
    alert("Please wait for the image to load before cropping.")
    return
  }

  this.cropper.getCroppedCanvas({
    width: 120,
    height: 120,
    imageSmoothingEnabled: true,
    imageSmoothingQuality: "high"
  }).toBlob(blob => {
    if (!blob) {
      alert("Failed to crop image.")
      return
    }

    // Update the file input with cropped image
    const file = new File([blob], "cropped.jpg", { type: "image/jpeg" })
    const dataTransfer = new DataTransfer()
    dataTransfer.items.add(file)
    this.inputTarget.files = dataTransfer.files

    // Show preview
    const url = URL.createObjectURL(blob)
    const previewEl = document.getElementById("cropper-preview-result")
    if (previewEl) {
      previewEl.src = url
      previewEl.classList.remove("d-none")
    }
  }, "image/jpeg")
}
}
