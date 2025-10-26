import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = []

  connect() {
    this.element.addEventListener('dragstart', this.dragStart.bind(this))
    this.element.addEventListener('dragover', this.dragOver.bind(this))
    this.element.addEventListener('drop', this.drop.bind(this))
    this.element.addEventListener('dragend', this.dragEnd.bind(this))
  }

  disconnect() {
    this.element.removeEventListener('dragstart', this.dragStart.bind(this))
    this.element.removeEventListener('dragover', this.dragOver.bind(this))
    this.element.removeEventListener('drop', this.drop.bind(this))
    this.element.removeEventListener('dragend', this.dragEnd.bind(this))
  }

  dragStart(e) {
    // Only allow drag from the drag handle
    if (!e.target.classList.contains('drag-handle') && !e.target.closest('.drag-handle')) {
      e.preventDefault()
      return
    }

    this.element.classList.add('opacity-50')
    e.dataTransfer.effectAllowed = 'move'
    e.dataTransfer.setData('text/html', this.element.innerHTML)
    e.dataTransfer.setData('exercise-id', this.element.dataset.exerciseId)
  }

  dragOver(e) {
    if (e.preventDefault) {
      e.preventDefault()
    }
    e.dataTransfer.dropEffect = 'move'
    return false
  }

  drop(e) {
    if (e.stopPropagation) {
      e.stopPropagation()
    }

    const draggedId = e.dataTransfer.getData('exercise-id')
    const droppedOnElement = e.target.closest('[data-controller="drag"]')

    if (droppedOnElement && draggedId !== droppedOnElement.dataset.exerciseId) {
      // Perform reorder via AJAX
      const draggedElement = document.querySelector(`[data-exercise-id="${draggedId}"]`)
      const newPosition = Array.from(droppedOnElement.parentNode.children).indexOf(droppedOnElement) + 1

      this.moveExercise(draggedId, newPosition)
    }

    return false
  }

  dragEnd(e) {
    this.element.classList.remove('opacity-50')
  }

  moveUp(e) {
    e.preventDefault()
    const currentPosition = this.getPosition()
    if (currentPosition > 1) {
      this.moveExercise(this.element.dataset.exerciseId, currentPosition - 1)
    }
  }

  moveDown(e) {
    e.preventDefault()
    const currentPosition = this.getPosition()
    const totalExercises = this.element.parentNode.children.length
    if (currentPosition < totalExercises) {
      this.moveExercise(this.element.dataset.exerciseId, currentPosition + 1)
    }
  }

  getPosition() {
    return Array.from(this.element.parentNode.children).indexOf(this.element) + 1
  }

  moveExercise(exerciseId, newPosition) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content

    fetch(`/exercises/${exerciseId}/move`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
        'Accept': 'text/vnd.turbo-stream.html'
      },
      body: JSON.stringify({ position: newPosition })
    })
    .then(response => response.text())
    .then(html => {
      if (html) {
        Turbo.renderStreamMessage(html)
      }
    })
    .catch(error => {
      console.error('Error moving exercise:', error)
    })
  }

  edit(e) {
    e.preventDefault()
    // Show edit form inline - for now we'll use a simple approach
    const exerciseId = this.element.dataset.exerciseId
    // This would be expanded to show an inline edit form
    console.log('Edit exercise:', exerciseId)
  }

  cancelEdit(e) {
    e.preventDefault()
    // Cancel inline edit
    console.log('Cancel edit')
  }
}
