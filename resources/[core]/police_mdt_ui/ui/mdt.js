class MDTInterface {
  constructor() {
    this.container = document.getElementById('mdt-container');
    this.currentPage = 'dashboard';
    this.searchInput = document.getElementById('search-input');
    this.systemTime = document.getElementById('system-time');
    this.init();
  }

  init() {
    this.setupMenuListeners();
    this.setupSearchListeners();
    this.updateSystemTime();
    setInterval(() => this.updateSystemTime(), 1000);
    this.loadDashboard();
  }

  setupMenuListeners() {
    document.querySelectorAll('.menu-item').forEach((item) => {
      item.addEventListener('click', () => {
        const page = item.dataset.page;
        this.switchPage(page);
      });
    });
  }

  switchPage(page) {
    document.querySelectorAll('.page').forEach((p) => p.classList.remove('active'));
    document.querySelectorAll('.menu-item').forEach((item) => item.classList.remove('active'));

    document.getElementById(`page-${page}`).classList.add('active');
    document.querySelector(`[data-page="${page}"]`).classList.add('active');

    this.currentPage = page;

    if (page === 'person-search') this.setupPersonSearch();
    if (page === 'vehicle-search') this.setupVehicleSearch();
    if (page === 'warrants') this.loadWarrants();
    if (page === 'bolo') this.loadBOLOs();
    if (page === 'cases') this.loadCases();
    if (page === 'evidence') this.loadEvidence();
  }

  setupSearchListeners() {
    document.getElementById('search-btn').addEventListener('click', () => {
      const query = this.searchInput.value;
      if (query.length < 2) {
        alert('Please enter at least 2 characters');
        return;
      }
      this.globalSearch(query);
    });

    this.searchInput.addEventListener('keypress', (e) => {
      if (e.key === 'Enter') {
        document.getElementById('search-btn').click();
      }
    });
  }

  globalSearch(query) {
    fetch(`https://police_mdt:server:searchPerson`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ search: query })
    });
  }

  setupPersonSearch() {
    const input = document.getElementById('person-search-input');
    const btn = document.getElementById('person-search-btn');

    btn.addEventListener('click', () => {
      const query = input.value;
      if (query.length < 2) return;

      this.searchPerson(query);
    });
  }

  searchPerson(query) {
    const resultsContainer = document.getElementById('person-results');
    resultsContainer.innerHTML = '<div class="no-results">Searching...</div>';

    // Mock data for demonstration
    const mockResults = [
      {
        id: 'npc_001',
        name: 'Matti Virtanen',
        age: 37,
        job: 'Mechanic',
        district: 'Downtown',
        lastSeen: 'Vespucci Blvd'
      },
      {
        id: 'npc_002',
        name: 'Janne Korhonen',
        age: 29,
        job: 'Civilian',
        district: 'Downtown',
        lastSeen: 'Market District'
      }
    ];

    setTimeout(() => {
      if (mockResults.length === 0) {
        resultsContainer.innerHTML = '<div class="no-results">No results found</div>';
        return;
      }

      resultsContainer.innerHTML = mockResults
        .map(
          (result) => `
        <div class="result-card" onclick="mdtInterface.viewPersonRecord('${result.id}')">
          <div class="result-header">
            <div class="result-name">${result.name}</div>
            <div class="result-job">${result.job}</div>
          </div>
          <div class="result-info">
            <div>Age: ${result.age}</div>
            <div>District: ${result.district}</div>
            <div>Last Seen: ${result.lastSeen}</div>
          </div>
        </div>
      `
        )
        .join('');
    }, 300);
  }

  viewPersonRecord(personId) {
    // Mock data
    const mockRecord = {
      id: personId,
      name: 'Matti Virtanen',
      age: 37,
      gender: 'Male',
      job: 'Mechanic',
      address: 'Palomino Ave 18',
      phone: '050-440-1802',
      license: 'Valid',
      licenseExpires: '2027-12-31',
      vehicles: [
        { plate: 'ABC-123', model: 'BMW 320' },
        { plate: 'XYZ-882', model: 'Volvo V70' }
      ],
      criminalRecord: [
        'Traffic Violation - 2024-03-15',
        'Public Disturbance - 2024-01-22'
      ],
      warrants: 0,
      bolos: 0
    };

    const content = `
      <div class="record-avatar">PHOTO</div>
      <div class="record-info">
        <div class="info-block">
          <div class="info-label">Full Name</div>
          <div class="info-value">${mockRecord.name}</div>
        </div>
        <div class="info-block">
          <div class="info-label">Age</div>
          <div class="info-value">${mockRecord.age}</div>
        </div>
        <div class="info-block">
          <div class="info-label">Gender</div>
          <div class="info-value">${mockRecord.gender}</div>
        </div>
        <div class="info-block">
          <div class="info-label">Job</div>
          <div class="info-value">${mockRecord.job}</div>
        </div>
        <div class="info-block">
          <div class="info-label">Address</div>
          <div class="info-value">${mockRecord.address}</div>
        </div>
        <div class="info-block">
          <div class="info-label">Phone</div>
          <div class="info-value">${mockRecord.phone}</div>
        </div>
        <div class="info-block">
          <div class="info-label">License</div>
          <div class="info-value">${mockRecord.license}</div>
        </div>
        <div class="info-block">
          <div class="info-label">Expires</div>
          <div class="info-value">${mockRecord.licenseExpires}</div>
        </div>
      </div>
      <div class="record-section">
        <div class="section-title">Vehicles</div>
        ${mockRecord.vehicles.map((v) => `<div class="record-item"><div class="record-item-title">${v.plate} - ${v.model}</div></div>`).join('')}
      </div>
      <div class="record-section">
        <div class="section-title">Criminal Record</div>
        ${mockRecord.criminalRecord.map((c) => `<div class="record-item"><div class="record-item-detail">${c}</div></div>`).join('')}
      </div>
      <div class="record-section">
        <div class="section-title">Flags</div>
        <div style="display:grid;grid-template-columns:repeat(2,1fr);gap:10px;">
          <div class="info-block"><div class="info-label">Warrants</div><div class="info-value">${mockRecord.warrants}</div></div>
          <div class="info-block"><div class="info-label">BOLO</div><div class="info-value">${mockRecord.bolos}</div></div>
        </div>
      </div>
    `;

    document.getElementById('person-record-content').innerHTML = content;
    document.getElementById('record-title').textContent = `Person Record - ${mockRecord.name}`;
    this.switchPage('person-record');
  }

  setupVehicleSearch() {
    const input = document.getElementById('vehicle-search-input');
    const btn = document.getElementById('vehicle-search-btn');

    btn.addEventListener('click', () => {
      const query = input.value;
      if (query.length < 2) return;

      this.searchVehicle(query);
    });
  }

  searchVehicle(query) {
    const resultsContainer = document.getElementById('vehicle-results');
    resultsContainer.innerHTML = '<div class="no-results">Searching...</div>';

    const mockResults = [
      {
        plate: 'ABC-123',
        model: 'BMW 320',
        owner: 'Matti Virtanen',
        stolen: false,
        registered: true,
        insurance: true
      }
    ];

    setTimeout(() => {
      if (mockResults.length === 0) {
        resultsContainer.innerHTML = '<div class="no-results">No results found</div>';
        return;
      }

      resultsContainer.innerHTML = mockResults
        .map(
          (result) => `
        <div class="result-card">
          <div class="result-header">
            <div class="result-name">${result.plate}</div>
            <div class="result-job">${result.model}</div>
          </div>
          <div class="result-info">
            <div>Owner: ${result.owner}</div>
            <div>Stolen: ${result.stolen ? 'YES' : 'NO'}</div>
            <div>Registered: ${result.registered ? 'YES' : 'NO'}</div>
            <div>Insurance: ${result.insurance ? 'YES' : 'NO'}</div>
          </div>
        </div>
      `
        )
        .join('');
    }, 300);
  }

  loadDashboard() {
    // Update dashboard cards with mock data
    document.getElementById('dash-calls').textContent = '12';
    document.getElementById('dash-warrants').textContent = '4';
    document.getElementById('dash-bolo').textContent = '7';
    document.getElementById('dash-cases').textContent = '31';

    const recentList = document.getElementById('recent-list');
    recentList.innerHTML = `
      <div class="activity-item">21:43 - Armed Robbery at Vespucci Blvd</div>
      <div class="activity-item">21:45 - Traffic Stop - Alta Street</div>
      <div class="activity-item">21:48 - Disturbance - Downtown Market</div>
    `;
  }

  loadWarrants() {
    const list = document.getElementById('warrants-list');
    list.innerHTML = `
      <div class="record-item">
        <div class="record-item-title">Warrant #W-2026-001</div>
        <div class="record-item-detail">Subject: Matti Virtanen | Reason: Armed Robbery</div>
      </div>
      <div class="record-item">
        <div class="record-item-title">Warrant #W-2026-002</div>
        <div class="record-item-detail">Subject: Unknown Male | Reason: Vehicle Theft</div>
      </div>
    `;
  }

  loadBOLOs() {
    const list = document.getElementById('bolo-list');
    list.innerHTML = `
      <div class="record-item">
        <div class="record-item-title">BOLO #B-2026-001</div>
        <div class="record-item-detail">Subject: Male, 30-40y, Dark Jacket | Vehicle: ABC-123</div>
      </div>
      <div class="record-item">
        <div class="record-item-title">BOLO #B-2026-002</div>
        <div class="record-item-detail">Subject: Armed & Dangerous | Last Seen: Vespucci</div>
      </div>
    `;
  }

  loadCases() {
    const list = document.getElementById('cases-list');
    list.innerHTML = `
      <div class="record-item">
        <div class="record-item-title">Case #2026-00981</div>
        <div class="record-item-detail">Armed Robbery - Status: Investigation In Progress</div>
      </div>
      <div class="record-item">
        <div class="record-item-title">Case #2026-00982</div>
        <div class="record-item-detail">Vehicle Theft - Status: Open</div>
      </div>
    `;
  }

  loadEvidence() {
    const list = document.getElementById('evidence-list');
    list.innerHTML = `
      <div class="record-item">
        <div class="record-item-title">EV-2026-001</div>
        <div class="record-item-detail">Type: Fingerprint | Case: #2026-00981 | Status: Match Found</div>
      </div>
      <div class="record-item">
        <div class="record-item-title">EV-2026-002</div>
        <div class="record-item-detail">Type: CCTV Footage | Case: #2026-00981 | Status: Analyzed</div>
      </div>
    `;
  }

  updateSystemTime() {
    const now = new Date();
    const hours = String(now.getHours()).padStart(2, '0');
    const minutes = String(now.getMinutes()).padStart(2, '0');
    this.systemTime.textContent = `${hours}:${minutes}`;
  }
}

let mdtInterface;
window.addEventListener('load', () => {
  mdtInterface = new MDTInterface();
});
