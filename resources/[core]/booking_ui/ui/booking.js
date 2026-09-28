class BookingUI {
  constructor() {
    this.container = document.getElementById('booking-container');
    this.timeDisplay = document.getElementById('booking-time');
    this.currentArrest = null;
    this.init();
  }

  init() {
    this.setupEventListeners();
    this.updateTime();
    setInterval(() => this.updateTime(), 1000);
  }

  setupEventListeners() {
    document.getElementById('booking-confirm').addEventListener('click', () => this.confirmBooking());
    document.getElementById('booking-release').addEventListener('click', () => this.releaseSubject());
    document.getElementById('booking-close').addEventListener('click', () => this.closeBooking());
  }

  showBooking(arrest) {
    this.currentArrest = arrest;
    this.loadBookingData(arrest);
    this.container.classList.remove('hidden');
  }

  hideBooking() {
    this.container.classList.add('hidden');
    this.currentArrest = null;
  }

  loadBookingData(arrest) {
    // Mock person data based on arrest
    const mockPerson = {
      id: arrest.personId,
      name: 'Matti Virtanen',
      age: 37,
      dob: '14.05.1989',
      gender: 'Male',
      address: 'Palomino Ave 18',
      phone: '050-440-1802'
    };

    document.getElementById('booking-name').textContent = mockPerson.name;
    document.getElementById('booking-age').textContent = mockPerson.age;
    document.getElementById('booking-dob').textContent = mockPerson.dob;
    document.getElementById('booking-gender').textContent = mockPerson.gender;
    document.getElementById('booking-address').textContent = mockPerson.address;
    document.getElementById('booking-phone').textContent = mockPerson.phone;

    document.getElementById('booking-id').textContent = arrest.id;
    document.getElementById('booking-time-in').textContent = arrest.bookedAt;
    document.getElementById('booking-release-time').textContent = arrest.releaseAt;
    document.getElementById('booking-duration').textContent = arrest.durationMinutes + ' minutes';
    document.getElementById('booking-officer').textContent = arrest.officerName;
    document.getElementById('booking-reason').textContent = arrest.reason;

    // Load charges
    const chargesHtml = arrest.reason
      .split(',')
      .map((charge) => `<div class="charge-item">• ${charge.trim()}</div>`)
      .join('');
    document.getElementById('booking-charges').innerHTML = chargesHtml || '<div class="charge-item">Unspecified</div>';
  }

  confirmBooking() {
    if (!this.currentArrest) return;

    console.log('Booking confirmed for arrest:', this.currentArrest.id);
    fetch(`https://booking_ui:server:confirmBooking`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ arrestId: this.currentArrest.id })
    });

    alert(`Booking confirmed for ${this.currentArrest.id}`);
  }

  releaseSubject() {
    if (!this.currentArrest) return;

    const confirm = window.confirm('Release subject from custody?');
    if (!confirm) return;

    console.log('Releasing subject from arrest:', this.currentArrest.id);
    fetch(`https://booking_ui:server:releaseSubject`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ arrestId: this.currentArrest.id })
    });

    alert(`Subject released from arrest ${this.currentArrest.id}`);
    this.hideBooking();
  }

  closeBooking() {
    this.hideBooking();
  }

  updateTime() {
    const now = new Date();
    const hours = String(now.getHours()).padStart(2, '0');
    const minutes = String(now.getMinutes()).padStart(2, '0');
    this.timeDisplay.textContent = `${hours}:${minutes}`;
  }
}

let bookingUI;
window.addEventListener('load', () => {
  bookingUI = new BookingUI();
});
