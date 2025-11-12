import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "action",
    "firstSelectContainer",
    "firstSelect",
    "firstLabel",
    "secondSelectContainer",
    "secondSelect",
    "secondLabel"
  ]

  static values = {
    realBuckets: Array,
    incomeBuckets: Array,
    spendingBuckets: Array,
    virtualBuckets: Array
  }

  connect() {
    this.updateForm()
  }

  updateForm() {
    const action = this.actionTarget.value

    switch(action) {
      case "income":
        this.setupIncomeForm()
        break
      case "expense":
        this.setupExpenseForm()
        break
      case "transfer":
        this.setupTransferForm()
        break
      default:
        this.hideSelects()
    }
  }

  setupIncomeForm() {
    this.showSelects()
    this.firstLabelTarget.textContent = "Income"
    this.secondLabelTarget.textContent = "Into"

    this.firstSelectTarget.name = "entry[from_account_id]"
    this.secondSelectTarget.name = "entry[to_account_id]"

    this.populateSelect(this.firstSelectTarget, this.incomeBucketsValue)
    this.populateSelect(this.secondSelectTarget, this.realBucketsValue)
  }

  setupExpenseForm() {
    this.showSelects()
    this.firstLabelTarget.textContent = "Bucket"
    this.secondLabelTarget.textContent = "From"

    this.firstSelectTarget.name = "entry[from_account_id]"
    this.secondSelectTarget.name = "entry[to_account_id]"

    this.populateSelect(this.firstSelectTarget, this.spendingBucketsValue)
    this.populateSelect(this.secondSelectTarget, this.realBucketsValue)
  }

  setupTransferForm() {
    this.showSelects()
    this.firstLabelTarget.textContent = "From"
    this.secondLabelTarget.textContent = "To"

    this.firstSelectTarget.name = "entry[from_account_id]"
    this.secondSelectTarget.name = "entry[to_account_id]"

    // Initially show all buckets for "from" select
    this.populateSelect(this.firstSelectTarget, [...this.realBucketsValue, ...this.virtualBucketsValue])

    // Update "to" select based on "from" selection
    this.updateTransferToSelect()
  }

  updateTransferToSelect() {
    const fromBucketId = parseInt(this.firstSelectTarget.value)
    const fromBucket = [...this.realBucketsValue, ...this.virtualBucketsValue]
      .find(b => b.id === fromBucketId)

    if (fromBucket) {
      if (fromBucket.real) {
        // From is real, so "to" must be real
        this.populateSelect(this.secondSelectTarget, this.realBucketsValue)
      } else {
        // From is virtual, so "to" must be virtual
        this.populateSelect(this.secondSelectTarget, this.virtualBucketsValue)
      }
    }
  }

  populateSelect(select, buckets) {
    const currentValue = select.value
    select.innerHTML = '<option value="">Select...</option>'

    buckets.forEach(bucket => {
      const option = document.createElement('option')
      option.value = bucket.id
      option.textContent = bucket.name
      if (bucket.id === parseInt(currentValue)) {
        option.selected = true
      }
      select.appendChild(option)
    })
  }

  showSelects() {
    this.firstSelectContainerTarget.style.display = 'block'
    this.secondSelectContainerTarget.style.display = 'block'
  }

  hideSelects() {
    this.firstSelectContainerTarget.style.display = 'none'
    this.secondSelectContainerTarget.style.display = 'none'
  }

  handleFromChange() {
    if (this.actionTarget.value === "transfer") {
      this.updateTransferToSelect()
    }
  }
}
