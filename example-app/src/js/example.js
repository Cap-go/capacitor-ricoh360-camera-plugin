import { CapacitorUpdater } from '@capgo/capacitor-updater';
import { Capacitor } from '@capacitor/core';
import { Ricoh360Camera } from '@capgo/capacitor-ricoh360';
import '../style.css';

const $ = (id) => document.getElementById(id);

const chipConnection = $('chip-connection');
const chipPreview = $('chip-preview');
const chipVersion = $('chip-version');
const outputLog = $('outputLog');
const lastPicture = $('lastPicture');
const previewPlaceholder = $('previewPlaceholder');
const cameraPreview = $('cameraPreview');

let connected = false;
let previewActive = false;
let connecting = false;
let connectGeneration = 0;

function setChip(el, label, state) {
  el.textContent = label;
  el.dataset.state = state;
}

function appendLog(title, payload) {
  const time = new Date().toLocaleTimeString();
  const body = typeof payload === 'string' ? payload : JSON.stringify(payload, null, 2);
  const entry = `[${time}] ${title}\n${body}\n\n`;
  outputLog.textContent = entry + outputLog.textContent;
}

function cameraUrl() {
  const ip = $('ipInput').value.trim();
  return `http://${ip}`;
}

function parseJsonField(id, fallback) {
  const raw = $(id).value.trim();
  if (!raw) {
    return fallback;
  }
  return JSON.parse(raw);
}

function showPreviewPlaceholder(message) {
  lastPicture.hidden = true;
  lastPicture.removeAttribute('src');
  previewPlaceholder.hidden = false;
  if (message) {
    previewPlaceholder.textContent = message;
  }
}

function setPreviewImage(url) {
  if (!url) {
    return;
  }
  lastPicture.onerror = () => {
    showPreviewPlaceholder('Could not load preview from the camera URL.');
  };
  lastPicture.onload = () => {
    lastPicture.hidden = false;
    previewPlaceholder.hidden = true;
  };
  lastPicture.src = url;
  $('assetUrl').value = url;
}

function dismissPreviewUi() {
  previewActive = false;
  cameraPreview.style.display = 'none';
  cameraPreview.setAttribute('aria-hidden', 'true');
  document.body.classList.remove('preview-mode');
  setChip(chipPreview, 'Preview off', 'idle');
}

function updateConnectionUi() {
  $('btn-connect').disabled = connecting || connected;
  $('btn-disconnect').disabled = !connected && !connecting;
  $('btn-live-preview').disabled = !connected || previewActive;
  $('btn-stop-preview').disabled = !previewActive;
  $('btn-capture-picture').disabled = !connected;
  $('btn-capture-video').disabled = !connected;
  $('btn-list-files').disabled = !connected;
  $('btn-get-asset').disabled = !connected;
  $('btn-read-settings').disabled = !connected;
  $('btn-set-settings').disabled = !connected;
  $('btn-send-command').disabled = !connected;
}

async function connect() {
  const generation = ++connectGeneration;
  connecting = true;
  setChip(chipConnection, 'Connecting...', 'warn');
  updateConnectionUi();
  try {
    const result = await Ricoh360Camera.initialize({ url: cameraUrl() });
    if (generation !== connectGeneration) {
      return;
    }
    connected = true;
    setChip(chipConnection, `Connected (${$('ipInput').value})`, 'ok');
    appendLog('initialize', result);
  } catch (error) {
    if (generation !== connectGeneration) {
      return;
    }
    connected = false;
    setChip(chipConnection, 'Connection failed', 'err');
    appendLog('initialize error', error.message ?? String(error));
  } finally {
    if (generation === connectGeneration) {
      connecting = false;
      updateConnectionUi();
    }
  }
}

async function disconnect() {
  connectGeneration += 1;
  if (connecting) {
    connecting = false;
    connected = false;
    setChip(chipConnection, 'Disconnected', 'idle');
    appendLog('disconnect', 'Canceled in-flight connection.');
    updateConnectionUi();
    return;
  }
  if (previewActive) {
    try {
      await stopLivePreview({ throwOnError: true });
    } catch (error) {
      setChip(chipConnection, 'Preview still active', 'warn');
      appendLog('disconnect blocked', error.message ?? String(error));
      updateConnectionUi();
      return;
    }
  }
  connected = false;
  setChip(chipConnection, 'Disconnected', 'idle');
  appendLog('disconnect', 'Session cleared in the demo UI. Reconnect to talk to the camera again.');
  updateConnectionUi();
}

async function getPluginVersion() {
  try {
    const result = await Ricoh360Camera.getPluginVersion();
    setChip(chipVersion, `Version: ${result.version}`, 'ok');
    appendLog('getPluginVersion', result);
  } catch (error) {
    setChip(chipVersion, 'Version: error', 'err');
    appendLog('getPluginVersion error', error.message ?? String(error));
  }
}

async function capturePicture() {
  try {
    const result = await Ricoh360Camera.capturePicture();
    appendLog('capturePicture', result);
    const fileUrl = result?.picture?.results?.fileUrl;
    if (fileUrl) {
      setPreviewImage(fileUrl);
    }
  } catch (error) {
    appendLog('capturePicture error', error.message ?? String(error));
  }
}

async function captureVideo() {
  const resolution = $('videoResolution').value;
  const frameRate = Number($('videoFrameRate').value) || 30;
  try {
    const result = await Ricoh360Camera.captureVideo({ resolution, frameRate });
    appendLog('captureVideo', result);
  } catch (error) {
    appendLog('captureVideo error', error.message ?? String(error));
  }
}

async function startLivePreview() {
  try {
    await Ricoh360Camera.livePreview({ displayInFront: false, cropPreview: false });
    previewActive = true;
    cameraPreview.style.display = 'block';
    cameraPreview.setAttribute('aria-hidden', 'false');
    document.body.classList.add('preview-mode');
    setChip(chipPreview, 'Preview on', 'ok');
    appendLog('livePreview', { displayInFront: false, cropPreview: false });
  } catch (error) {
    appendLog('livePreview error', error.message ?? String(error));
  }
  updateConnectionUi();
}

async function stopLivePreview(options = {}) {
  const { throwOnError = false, forceUi = false } = options;
  try {
    await Ricoh360Camera.stopLivePreview();
    dismissPreviewUi();
    appendLog('stopLivePreview', { status: 'stopped' });
    updateConnectionUi();
    return true;
  } catch (error) {
    appendLog('stopLivePreview error', error.message ?? String(error));
    if (forceUi) {
      dismissPreviewUi();
      appendLog('stopLivePreview', 'Toolbar hidden in the WebView. Retry stop if preview persists on device.');
      updateConnectionUi();
      return false;
    }
    if (throwOnError) {
      throw error;
    }
    updateConnectionUi();
    return false;
  }
}

async function listFiles() {
  try {
    const result = await Ricoh360Camera.listFiles({
      fileType: 'all',
      startPosition: 0,
      entryCount: 20,
      maxThumbSize: 0,
      _detail: true,
    });
    appendLog('listFiles', result);
    const first = result?.results?.entries?.[0];
    if (first?.fileUrl) {
      $('assetUrl').placeholder = first.fileUrl;
    }
  } catch (error) {
    appendLog('listFiles error', error.message ?? String(error));
  }
}

async function getCameraAsset() {
  const url = $('assetUrl').value.trim() || $('assetUrl').placeholder;
  if (!url || url.startsWith('fileUrl')) {
    appendLog('getCameraAsset error', 'Set Asset URL from listFiles first.');
    return;
  }
  try {
    const result = await Ricoh360Camera.getCameraAsset({ url, saveToFile: false });
    appendLog('getCameraAsset', {
      statusCode: result.statusCode,
      dataLength: result.data?.length ?? 0,
      filePath: result.filePath,
    });
    if (result.data) {
      setPreviewImage(`data:image/jpeg;base64,${result.data}`);
    }
  } catch (error) {
    appendLog('getCameraAsset error', error.message ?? String(error));
  }
}

async function readSettings() {
  try {
    const options = parseJsonField('readOptions', []);
    const result = await Ricoh360Camera.readSettings({ options });
    appendLog('readSettings', result);
  } catch (error) {
    appendLog('readSettings error', error.message ?? String(error));
  }
}

async function setSettings() {
  try {
    const options = parseJsonField('setOptions', {});
    const result = await Ricoh360Camera.setSettings({ options });
    appendLog('setSettings', result);
  } catch (error) {
    appendLog('setSettings error', error.message ?? String(error));
  }
}

async function sendCommand() {
  try {
    const endpoint = $('commandEndpoint').value.trim();
    const payload = parseJsonField('commandPayload', {});
    const result = await Ricoh360Camera.sendCommand({ endpoint, payload });
    appendLog('sendCommand', result);
  } catch (error) {
    appendLog('sendCommand error', error.message ?? String(error));
  }
}

function clearLog() {
  outputLog.textContent = 'Log cleared.';
}

$('btn-connect').addEventListener('click', connect);
$('btn-disconnect').addEventListener('click', disconnect);
$('btn-plugin-version').addEventListener('click', getPluginVersion);
$('btn-capture-picture').addEventListener('click', capturePicture);
$('btn-capture-video').addEventListener('click', captureVideo);
$('btn-live-preview').addEventListener('click', startLivePreview);
$('btn-stop-preview').addEventListener('click', stopLivePreview);
$('btn-list-files').addEventListener('click', listFiles);
$('btn-get-asset').addEventListener('click', getCameraAsset);
$('btn-read-settings').addEventListener('click', readSettings);
$('btn-set-settings').addEventListener('click', setSettings);
$('btn-send-command').addEventListener('click', sendCommand);
$('btn-clear-log').addEventListener('click', clearLog);
$('btn-overlay-capture').addEventListener('click', capturePicture);
$('btn-overlay-close').addEventListener('click', async () => {
  const stopped = await stopLivePreview();
  if (!stopped) {
    await stopLivePreview({ forceUi: true });
  }
});

lastPicture.addEventListener('error', () => {
  showPreviewPlaceholder('Could not load preview from the camera URL.');
});

updateConnectionUi();
getPluginVersion();

if (Capacitor.isNativePlatform()) {
  CapacitorUpdater.notifyAppReady().catch((error) => {
    console.error('Capgo notifyAppReady failed', error);
  });
}
