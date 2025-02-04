<template>
  <ion-page>
    <ion-header v-if="!isPreviewActive">
      <ion-toolbar>
        <ion-title>Ricoh360 Camera</ion-title>
      </ion-toolbar>
    </ion-header>
    <ion-content :fullscreen="true">
      <div class="camera-container">
        <!-- Main Content -->
        <div id="mainContent" v-show="!isPreviewActive">
          <div class="setup">
            <ion-item>
              <ion-label position="stacked">Camera IP:</ion-label>
              <ion-input v-model="cameraIp" placeholder="192.168.1.1"></ion-input>
            </ion-item>
            <ion-button @click="openCamera(false)">Open Camera</ion-button>
            <ion-button @click="openCamera(true)">Open Camera (crop)</ion-button>
            <ion-button @click="readSettings">Read Settings</ion-button>
            <ion-button @click="setSettings">Set Settings</ion-button>
            <ion-button @click="sendCommand">Send Command</ion-button>
            <ion-button @click="listPhotos">Read Photos</ion-button>
          </div>
          <pre class="settings-value">{{ settingsValue }}</pre>
          <img :src="lastPictureUrl" class="last-picture" v-if="lastPictureUrl" />
        </div>

        <!-- Camera Preview -->
        <div id="cameraPreview" v-show="isPreviewActive">
          <div class="button-container">
            <ion-button @click="takePicture">Take Picture</ion-button>
            <ion-button @click="closeCamera">Close Camera</ion-button>
          </div>
        </div>
      </div>
    </ion-content>
  </ion-page>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue';
import { 
  IonPage, 
  IonHeader, 
  IonToolbar, 
  IonTitle, 
  IonContent,
  IonButton,
  IonItem,
  IonLabel,
  IonInput
} from '@ionic/vue';
import { Ricoh360Camera } from '@capgo/ricoh360';

const cameraIp = ref('192.168.1.1');
const isPreviewActive = ref(false);
const settingsValue = ref('');
const lastPictureUrl = ref('');

watch(isPreviewActive, (newVal: boolean) => {
  if (newVal) {
    const styleElement = document.createElement('style');
    styleElement.textContent = 
    `:root {
      --ion-background-color: transparent !important;
    }`;
    styleElement.id = 'magic_61652e0d-6530-4015-aa6d-7686e0038bc5'
    document.head.appendChild(styleElement)
  } else {
    const styleElement = document.getElementById('magic_61652e0d-6530-4015-aa6d-7686e0038bc5');
    if (styleElement) {
      document.head.removeChild(styleElement);
    }
  }
});

async function openCamera(crop: boolean) {
  try {
    await Ricoh360Camera.initialize({
      url: `http://${cameraIp.value}`
    });
    isPreviewActive.value = true;
    await Ricoh360Camera.livePreview({ displayInFront: false, cropPreview: crop });
    console.log("Camera opened");
  } catch (e) {
    console.error(e);
  }
}

async function closeCamera() {
  try {
    await Ricoh360Camera.stopLivePreview();
    isPreviewActive.value = false;
  } catch (e) {
    console.error(e);
  }
}

async function takePicture() {
  try {
    const result = await Ricoh360Camera.capturePicture();
  } catch (e) {
    console.error(e);
  }
}

async function readSettings() {
  try {
    const optionsToRead = [
      "iso",
      "shutterSpeed",
      "whiteBalance",
      "exposureProgram",
      "exposureCompensation",
      "fileFormat"
    ];
    const result = await Ricoh360Camera.readSettings({ options: optionsToRead });
    settingsValue.value = JSON.stringify(result, null, 2);
  } catch (e) {
    console.error(e);
    settingsValue.value = `Error: ${(e as any).message}`;
  }
}

async function setSettings() {
  try {
    const settings = {
      iso: 0,
    };
    const result = await Ricoh360Camera.setSettings({ options: settings });
    settingsValue.value = JSON.stringify(result, null, 2);
  } catch (e) {
    console.error(e);
    settingsValue.value = `Error: ${(e as any).message}`;
  }
}

async function sendCommand() {
  try {
    const result = await Ricoh360Camera.sendCommand({
      endpoint: '/osc/commands/execute',
      payload: {
        name: "camera.getOptions",
        parameters: {
          optionNames: ["shutterSpeed", "iso", 'captureIntervalSupport']
        }
      }
    });
    settingsValue.value = JSON.stringify(result, null, 2);
  } catch (e) {
    console.error(e);
    settingsValue.value = `Error: ${(e as any).message}`;
  }
}

async function listPhotos() {
  try {
    const result = await Ricoh360Camera.sendCommand({
      endpoint: '/osc/commands/execute',
      payload: {
        name: "camera.listFiles",
        parameters: {
          "fileType": "all",
          "startPosition": 0,
          "entryCount": 100,
          "maxThumbSize": 0,
          "_detail": true
        }
      }
    });
    settingsValue.value = JSON.stringify(result, null, 2);
  } catch (e) {
    console.error(e);
    settingsValue.value = `Error: ${(e as any).message}`;
  }
}
</script>

<style scoped>
.camera-container {
  height: 100%;
}

.setup {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  padding: 1rem;
}

.settings-value {
  color: black;
  font-family: monospace;
  background: #f5f5f5;
  padding: 1rem;
  margin: 1rem;
  border-radius: 4px;
  white-space: pre-wrap;
  word-break: break-all;
}

.last-picture {
  max-width: 100%;
  max-height: 50vh;
  margin: 1rem auto;
  display: block;
}

#cameraPreview {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: transparent;
}

.button-container {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1rem;
  padding: 1rem;
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: rgba(0,0,0,0.5);
}
</style>
