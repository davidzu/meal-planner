import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["template", "container"]

  connect() {
    this.form = this.element.closest("form")
    this.form?.addEventListener("click", this.onClick)
    this.form?.addEventListener("keydown", this.onKeydown)
    this.form?.addEventListener("invalid", this.onInvalid, true)
    this.element.addEventListener("change", this.onChange)
  }

  disconnect() {
    this.form?.removeEventListener("click", this.onClick)
    this.form?.removeEventListener("keydown", this.onKeydown)
    this.form?.removeEventListener("invalid", this.onInvalid, true)
    this.element.removeEventListener("change", this.onChange)
  }

  add(event) {
    event.preventDefault()
    const html = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, Date.now().toString())
    this.containerTarget.insertAdjacentHTML("beforeend", html)
  }

  onChange = (event) => {
    if (!event.target.matches("input[type=checkbox][name*='[_destroy]']")) return
    this.setRowSkipped(event.target.closest(".ingredient-fields"), event.target.checked)
  }

  onClick = (event) => {
    if (!event.target.closest("[type=submit], button:not([type])")) return
    this.skipInvalidRows()
  }

  onKeydown = (event) => {
    if (event.key !== "Enter") return
    if (event.target.matches("textarea, button, [type=submit]")) return
    this.skipInvalidRows()
  }

  onInvalid = () => {
    this.temporarilySkipped?.forEach((field) => { field.disabled = false })
    this.temporarilySkipped = []
  }

  skipInvalidRows() {
    this.temporarilySkipped = []
    this.containerTarget.querySelectorAll(".ingredient-fields").forEach((row) => {
      if (!this.shouldSkip(row)) return
      this.setRowSkipped(row, true, this.temporarilySkipped)
    })
  }

  shouldSkip(row) {
    if (row.querySelector("input[type=checkbox][name*='[_destroy]']")?.checked) return true
    return this.isEmpty(row)
  }

  isEmpty(row) {
    const quantity = row.querySelector("input[name*='[quantity]']")?.value
    const ingredientId = row.querySelector("select[name*='[ingredient_id]']")?.value
    const name = row.querySelector("input[name*='[ingredient_name]']")?.value?.trim()
    const unit = row.querySelector("input[name*='[unit]']")?.value?.trim()
    const note = row.querySelector("input[name*='[prep_note]']")?.value?.trim()
    const qtyBlank = quantity === "" || Number(quantity) === 0
    return qtyBlank && !ingredientId && !name && !unit && !note
  }

  setRowSkipped(row, skipped, restored) {
    if (!row) return
    row.querySelectorAll("input, select, textarea").forEach((field) => {
      if (field.name?.includes("[_destroy]") || field.name?.includes("[id]")) return
      if (skipped) {
        if (field.disabled) return
        field.disabled = true
        restored?.push(field)
      } else {
        field.disabled = false
      }
    })
  }
}
