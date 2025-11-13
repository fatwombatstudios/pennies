import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "incomeBucketSelect",
    "availableSection",
    "availableAmount",
    "allocationsSection",
    "submitSection",
    "allocationInput",
    "submitButton"
  ]

  static values = {
    incomeBuckets: Array,
    spendingBuckets: Array
  }

  connect() {
    this.selectedIncomeBucket = null
  }

  incomeChanged() {
    const selectedId = parseInt(this.incomeBucketSelectTarget.value)

    if (selectedId) {
      this.selectedIncomeBucket = this.incomeBucketsValue.find(b => b.id === selectedId)

      if (this.selectedIncomeBucket) {
        this.showAllocationForm()
        this.calculateRemaining()
      }
    } else {
      this.hideAllocationForm()
    }
  }

  calculateRemaining() {
    if (!this.selectedIncomeBucket) return

    let totalAllocated = 0
    this.allocationInputTargets.forEach(input => {
      const value = parseFloat(input.value) || 0
      totalAllocated += value
    })

    const remaining = this.selectedIncomeBucket.balance - totalAllocated
    this.availableAmountTarget.textContent = this.formatCurrency(remaining)

    // Update styling based on remaining amount
    if (remaining < 0) {
      this.availableAmountTarget.style.color = '#e53e3e' // Red
      this.submitButtonTarget.disabled = true
    } else if (remaining === 0) {
      this.availableAmountTarget.style.color = '#38a169' // Green
      this.submitButtonTarget.disabled = false
    } else {
      this.availableAmountTarget.style.color = '#2c5282' // Blue
      this.submitButtonTarget.disabled = false
    }
  }

  showAllocationForm() {
    this.availableSectionTarget.style.display = 'block'
    this.allocationsSectionTarget.style.display = 'block'
    this.submitSectionTarget.style.display = 'block'
  }

  hideAllocationForm() {
    this.availableSectionTarget.style.display = 'none'
    this.allocationsSectionTarget.style.display = 'none'
    this.submitSectionTarget.style.display = 'none'
    this.selectedIncomeBucket = null
  }

  formatCurrency(amount) {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD'
    }).format(amount)
  }
}
