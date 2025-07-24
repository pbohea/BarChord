import { Controller } from "@hotwired/stimulus"
import Cropper from "cropperjs"

export default class extends Controller {
  static targets = ["input", "preview", "saveButton"]

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
          background: false,
          modal: true,
          guides: false,
          highlight: false,
          cropBoxResizable: true,
          cropBoxMovable: true,
          dragMode: "move",
          scalable: false,
          zoomable: false,
        })

        // Show "Save" button once cropper is initialized
        this.saveButtonTarget.classList.remove("d-none")
      }

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
    alert("Please wait for the image to load before saving.")
    return
  }

  const canvas = this.cropper.getCroppedCanvas({
    width: 160,
    height: 160,
    imageSmoothingEnabled: true,
    imageSmoothingQuality: "high"
  })

  canvas.toBlob(blob => {
    if (!blob) {
      alert("Failed to crop image.")
      return
    }

    const uniqueFilename = `artist_${Date.now()}.jpg`
    const file = new File([blob], uniqueFilename, { type: "image/jpeg" })

    const dataTransfer = new DataTransfer()
    dataTransfer.items.add(file)
    this.inputTarget.files = dataTransfer.files

    const previewEl = document.getElementById("cropper-preview-result")
    const labelEl = document.getElementById("cropped-preview-label")
    if (previewEl && labelEl) {
      previewEl.src = URL.createObjectURL(blob)
      previewEl.classList.remove("d-none")
      labelEl.classList.remove("d-none")
    }
  }, "image/jpeg")
}
}
