import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "list", "item"]

  connect() {
    this.inputTarget.focus()
  }

  filter() {
    const term = this.inputTarget.value.trim().toLowerCase()
    this.itemTargets.forEach((item) => {
      item.hidden = term.length > 0 && !item.dataset.name.includes(term)
    })
  }
}