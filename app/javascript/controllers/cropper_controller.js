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
          aspectRatio: 1,                // maintain square crop
          viewMode: 1,
          autoCropArea: 1,
          responsive: true,
          background: false,             // cleaner look
          modal: true,                   // darken outside
          guides: false,
          highlight: false,
          cropBoxResizable: true,
          cropBoxMovable: true,
          dragMode: 'move',
          scalable: false,
          zoomable: false,
        })
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
      alert("Please wait for the image to load before cropping.")
      return
    }

    const canvas = this.cropper.getCroppedCanvas({
      width: 120,
      height: 120,
      imageSmoothingEnabled: true,
      imageSmoothingQuality: "high"
    })

    canvas.toBlob(blob => {
      if (!blob) {
        alert("Failed to crop image.")
        return
      }

      // Replace file input with cropped blob
      const file = new File([blob], "cropped.jpg", { type: "image/jpeg" })
      const dataTransfer = new DataTransfer()
      dataTransfer.items.add(file)
      this.inputTarget.files = dataTransfer.files

      // Show the cropped circular preview
      const url = URL.createObjectURL(blob)
      const previewEl = document.getElementById("cropper-preview-result")
      if (previewEl) {
        previewEl.src = url
        previewEl.classList.remove("d-none")
      }
    }, "image/jpeg")
  }
}
