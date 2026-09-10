import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener("invalid", this.handleInvalid, true)
    this.element.addEventListener("input", this.clearValidity, true)
    this.element.addEventListener("change", this.clearValidity, true)
  }

  disconnect() {
    this.element.removeEventListener("invalid", this.handleInvalid, true)
    this.element.removeEventListener("input", this.clearValidity, true)
    this.element.removeEventListener("change", this.clearValidity, true)
  }

  handleInvalid = (event) => {
    const field = event.target
    if (typeof field.setCustomValidity !== "function") return
    field.setCustomValidity(this.messageFor(field))
  }

  clearValidity = (event) => {
    const field = event.target
    if (typeof field.setCustomValidity === "function") field.setCustomValidity("")
  }

  messageFor(field) {
    const validity = field.validity
    if (validity.valueMissing) return "Completa este campo."
    if (validity.typeMismatch && field.type === "email") return "Introduce un correo válido."
    if (validity.typeMismatch) return "Introduce un valor válido."
    if (validity.stepMismatch || validity.rangeUnderflow || validity.rangeOverflow || validity.badInput) {
      return "Introduce un valor válido."
    }
    if (validity.tooShort) return "El texto es demasiado corto."
    if (validity.tooLong) return "El texto es demasiado largo."
    if (validity.patternMismatch) return "El formato no es válido."
    return "Introduce un valor válido."
  }
}
