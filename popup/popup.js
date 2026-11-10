const options = [
  { id: 'skipRecap', timerId: 'recapTimer' },
  { id: 'skipIntro', timerId: 'introTimer' },
  { id: 'skipCredits', timerId: 'creditsTimer' }
];

// Safari and Firefox expose the promise-based `browser` namespace; Chrome exposes `chrome`.
const api = (typeof browser !== 'undefined' && browser.runtime) ? browser : chrome;

// Load settings
api.storage.local.get(options.flatMap(o => [o.id, o.timerId])).then((result) => {
  options.forEach(option => {
    document.getElementById(option.id).checked = result[option.id] !== false; // Default to true if not set
    document.getElementById(option.timerId).value = result[option.timerId] || 0;
  });
});

// Set version number
document.getElementById('version').textContent = `v${api.runtime.getManifest().version}`;

function showStatus() {
  const status = document.getElementById('status');
  status.textContent = 'Settings saved!';
  status.style.color = '#f47521';
  setTimeout(() => {
    status.textContent = 'AutoSave On';
    status.style.color = '#888';
  }, 1000);
}

// Save settings on change
options.forEach(option => {
  document.getElementById(option.id).addEventListener('change', (e) => {
    api.storage.local.set({ [option.id]: e.target.checked }).then(showStatus);
  });

  document.getElementById(option.timerId).addEventListener('input', (e) => {
    const value = parseInt(e.target.value, 10);
    if (!isNaN(value) && value >= 0) {
      api.storage.local.set({ [option.timerId]: value }).then(showStatus);
    }
  });
});

// Safari does not reliably open target="_blank" links from an extension popup
// (notably on iOS/iPadOS), so open them through the tabs API in every browser.
document.querySelectorAll('a[target="_blank"]').forEach(link => {
  link.addEventListener('click', (e) => {
    e.preventDefault();
    api.tabs.create({ url: link.href }).then(() => window.close());
  });
});
