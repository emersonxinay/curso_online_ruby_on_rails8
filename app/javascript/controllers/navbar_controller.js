import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['mobileMenu', 'dropdown']
  static classes = ['hidden']

  connect() {
    // Cerrar al hacer clic fuera
    this.handleOutsideClicks = this.handleOutsideClicks.bind(this)
    document.addEventListener('click', this.handleOutsideClicks)

    // Cerrar al presionar Escape
    this.handleEscapeKey = this.handleEscapeKey.bind(this)
    document.addEventListener('keydown', this.handleEscapeKey)
  }

  disconnect() {
    document.removeEventListener('click', this.handleOutsideClicks)
    document.removeEventListener('keydown', this.handleEscapeKey)
  }

  toggleMobileMenu() {
    this.mobileMenuTarget.classList.toggle(this.hiddenClass)
  }

  toggleDropdown(event) {
    const dropdown = event.currentTarget.nextElementSibling
    dropdown.classList.toggle(this.hiddenClass)

    // Cerrar otros dropdowns
    this.dropdownTargets.forEach(otherDropdown => {
      if (otherDropdown !== dropdown && !otherDropdown.classList.contains(this.hiddenClass)) {
        otherDropdown.classList.add(this.hiddenClass)
      }
    })
  }

  handleOutsideClicks(event) {
    // Cerrar menú móvil si se hace clic fuera
    if (this.hasMobileMenuTarget && !this.element.contains(event.target)) {
      this.mobileMenuTarget.classList.add(this.hiddenClass)
    }

    // Cerrar dropdowns si se hace clic fuera
    this.dropdownTargets.forEach(dropdown => {
      if (!dropdown.contains(event.target) && !dropdown.previousElementSibling.contains(event.target)) {
        dropdown.classList.add(this.hiddenClass)
      }
    })
  }

  handleEscapeKey(event) {
    if (event.key === 'Escape') {
      // Cerrar menú móvil
      if (this.hasMobileMenuTarget) {
        this.mobileMenuTarget.classList.add(this.hiddenClass)
      }

      // Cerrar todos los dropdowns
      this.dropdownTargets.forEach(dropdown => {
        dropdown.classList.add(this.hiddenClass)
      })
    }
  }
}