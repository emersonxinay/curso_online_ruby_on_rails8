import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['mobileMenu', 'dropdown']
  static classes = ['hidden']

  connect() {
    console.log('NavbarController conectado')
    this.handleOutsideClicks = this.handleOutsideClicks.bind(this)
    this.handleEscapeKey = this.handleEscapeKey.bind(this)
    document.addEventListener('click', this.handleOutsideClicks)
    document.addEventListener('keydown', this.handleEscapeKey)
  }

  disconnect() {
    document.removeEventListener('click', this.handleOutsideClicks)
    document.removeEventListener('keydown', this.handleEscapeKey)
  }

  toggleMobileMenu(event) {
    event.stopPropagation() // Evitar que el clic se propague
    this.mobileMenuTarget.classList.toggle(this.hiddenClass)

    const openIcon = this.element.querySelector('.mobile-menu-open')
    const closeIcon = this.element.querySelector('.mobile-menu-close')

    if (openIcon && closeIcon) {
      openIcon.classList.toggle('hidden')
      closeIcon.classList.toggle('hidden')
    }
  }

  toggleDropdown(event) {
    event.stopPropagation() // Evitar que el clic se propague
    const currentDropdown = event.currentTarget.nextElementSibling

    if (!this.dropdownTargets.includes(currentDropdown)) {
      console.error('Dropdown no encontrado')
      return
    }

    // Cerrar otros dropdowns primero
    this.dropdownTargets.forEach(dropdown => {
      if (dropdown !== currentDropdown) {
        dropdown.classList.add(this.hiddenClass)
      }
    })

    // Alternar el dropdown actual
    currentDropdown.classList.toggle(this.hiddenClass)
  }

  handleOutsideClicks(event) {
    // Ignorar clics en los botones de toggle
    if (event.target.closest('[data-action*="navbar#toggle"]')) {
      return
    }

    // Cerrar dropdowns si el clic fue fuera
    this.dropdownTargets.forEach(dropdown => {
      if (!dropdown.contains(event.target) &&
        !dropdown.previousElementSibling.contains(event.target)) {
        dropdown.classList.add(this.hiddenClass)
      }
    })

    // Cerrar menú móvil si el clic fue fuera
    if (this.hasMobileMenuTarget &&
      !this.mobileMenuTarget.contains(event.target) &&
      !this.element.querySelector('[data-action*="navbar#toggleMobileMenu"]').contains(event.target)) {
      this.mobileMenuTarget.classList.add(this.hiddenClass)

      const openIcon = this.element.querySelector('.mobile-menu-open')
      const closeIcon = this.element.querySelector('.mobile-menu-close')

      if (openIcon && closeIcon) {
        openIcon.classList.remove('hidden')
        closeIcon.classList.add('hidden')
      }
    }
  }

  handleEscapeKey(event) {
    if (event.key === 'Escape') {
      this.dropdownTargets.forEach(dropdown => {
        dropdown.classList.add(this.hiddenClass)
      })

      if (this.hasMobileMenuTarget) {
        this.mobileMenuTarget.classList.add(this.hiddenClass)

        const openIcon = this.element.querySelector('.mobile-menu-open')
        const closeIcon = this.element.querySelector('.mobile-menu-close')

        if (openIcon && closeIcon) {
          openIcon.classList.remove('hidden')
          closeIcon.classList.add('hidden')
        }
      }
    }
  }
}