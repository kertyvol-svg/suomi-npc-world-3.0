// Mock data for demonstration
const mockCalls = [
  {
    id: 'call_001',
    type: 'armed_robbery',
    location: 'Vespucci Blvd 24',
    severity: 'high',
    suspect: 'Matti Virtanen',
    vehicle: 'ABC-123 / BMW 320',
    description: 'Witness reported armed suspect fleeing from the scene. Suspect seen with weapon.',
    witnesses: 2,
    time: '21:43'
  },
  {
    id: 'call_002',
    type: 'traffic_stop',
    location: 'Alta Street',
    severity: 'medium',
    suspect: 'Unknown Male',
    vehicle: 'Black sedan',
    description: 'Erratic driving behavior reported. Vehicle matching stolen vehicle report.',
    witnesses: 1,
    time: '21:45'
  },
  {
    id: 'call_003',
    type: 'disturbance',
    location: 'Downtown Market',
    severity: 'medium',
    suspect: 'Unknown',
    vehicle: 'N/A',
    description: 'Public disturbance reported. Multiple subjects involved in altercation.',
    witnesses: 3,
    time: '21:48'
  }
];

const mockUnits = [
  { id: '301', status: 'available' },
  { id: '305', status: 'busy' },
  { id: '312', status: 'enroute' },
  { id: '318', status: 'onscene' },
  { id: '320', status: 'available' }
];

class DispatchUI {
  constructor() {
    this.container = document.getElementById('dispatch-container');
    this.callsList = document.getElementById('calls-list');
    this.unitsList = document.getElementById('units-list');
    this.callCounter = document.getElementById('call-counter');
    this.callDetails = document.getElementById('call-details');
    this.yourUnitId = document.getElementById('your-unit-id');
    this.yourStatus = document.getElementById('your-status');
    this.currentSelectedCall = null;

    this.init();
  }

  init() {
    this.renderCalls();
    this.renderUnits();
    this.setupEventListeners();
  }

  renderCalls() {
    this.callsList.innerHTML = '';
    this.callCounter.textContent = mockCalls.length;

    mockCalls.forEach((call) => {
      const callElement = document.createElement('div');
      callElement.className = `call-item priority-${call.severity === 'high' ? 'high' : call.severity === 'medium' ? 'medium' : 'low'}`;
      callElement.innerHTML = `
        <div class="call-type">${call.type.replace(/_/g, ' ')}</div>
        <div class="call-location">📍 ${call.location}</div>
        <div class="call-time">🕐 ${call.time}</div>
      `;
      callElement.addEventListener('click', () => this.selectCall(call, callElement));
      this.callsList.appendChild(callElement);
    });
  }

  renderUnits() {
    this.unitsList.innerHTML = '';

    mockUnits.forEach((unit) => {
      const unitElement = document.createElement('div');
      unitElement.className = 'unit-item';
      unitElement.innerHTML = `
        <div class="unit-id">🚓 Unit ${unit.id}</div>
        <div class="unit-status ${unit.status}">${unit.status.toUpperCase().replace('_', ' ')}</div>
      `;
      this.unitsList.appendChild(unitElement);
    });
  }

  selectCall(call, element) {
    // Remove active class from all calls
    document.querySelectorAll('.call-item').forEach((item) => item.classList.remove('active'));
    element.classList.add('active');

    this.currentSelectedCall = call;
    this.showCallDetails(call);
  }

  showCallDetails(call) {
    document.getElementById('detail-title').textContent = call.type.replace(/_/g, ' ').toUpperCase();
    document.getElementById('detail-location').textContent = call.location;
    document.getElementById('detail-type').textContent = call.type.replace(/_/g, ' ');
    document.getElementById('detail-severity').textContent = call.severity.toUpperCase();
    document.getElementById('detail-suspect').textContent = call.suspect;
    document.getElementById('detail-vehicle').textContent = call.vehicle;
    document.getElementById('detail-description').textContent = call.description;
    document.getElementById('detail-witnesses').textContent = `${call.witnesses} witness${call.witnesses !== 1 ? 'es' : ''}`;

    this.callDetails.classList.remove('hidden');
  }

  setupEventListeners() {
    document.getElementById('close-details').addEventListener('click', () => {
      this.callDetails.classList.add('hidden');
    });

    document.getElementById('accept-call-btn').addEventListener('click', () => {
      if (this.currentSelectedCall) {
        console.log(`Accepted call: ${this.currentSelectedCall.id}`);
        alert(`Call ${this.currentSelectedCall.id} accepted!`);
      }
    });

    document.getElementById('view-mdt-btn').addEventListener('click', () => {
      if (this.currentSelectedCall) {
        console.log(`Opening MDT for: ${this.currentSelectedCall.suspect}`);
        alert(`Opening MDT for ${this.currentSelectedCall.suspect}`);
      }
    });

    document.getElementById('navigate-btn').addEventListener('click', () => {
      if (this.currentSelectedCall) {
        console.log(`Navigating to: ${this.currentSelectedCall.location}`);
        alert(`Setting GPS to: ${this.currentSelectedCall.location}`);
      }
    });

    document.getElementById('status-available').addEventListener('click', () => this.setStatus('available'));
    document.getElementById('status-busy').addEventListener('click', () => this.setStatus('busy'));
    document.getElementById('status-enroute').addEventListener('click', () => this.setStatus('enroute'));
    document.getElementById('status-onscene').addEventListener('click', () => this.setStatus('onscene'));
  }

  setStatus(status) {
    const statusElement = document.getElementById('your-status');
    statusElement.className = `value status-${status}`;
    statusElement.textContent = status.replace('_', ' ').toUpperCase();
    console.log(`Unit status changed to: ${status}`);
  }
}

// Initialize on page load
window.addEventListener('load', () => {
  new DispatchUI();
});
