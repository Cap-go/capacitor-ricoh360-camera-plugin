<template>
  <ion-page>
    <ion-header>
      <ion-toolbar>
        <ion-title>Tab 2</ion-title>
      </ion-toolbar>
    </ion-header>
    <ion-content :fullscreen="true">
      <ion-header collapse="condense">
        <ion-toolbar>
          <ion-title size="large">Tab 2</ion-title>
        </ion-toolbar>
      </ion-header>
      <template v-if="!showPreview">
          <ion-button @click="listPhotos">Open Camera</ion-button>
        
          <ion-list>
            <ion-item v-for="photo in photos" :key="photo.name">
              <ion-label>{{ photo.name }}</ion-label>
              <div slot="end">
                <ion-button @click="openPhoto(photo)">Open</ion-button>
                <ion-button @click="downloadPhoto(photo)">Download</ion-button>
              </div>
            </ion-item>
          </ion-list>
      </template>
      <template v-else>
        <div id="previewMagic-container-to-test">
        </div>
      </template>
    </ion-content>
  </ion-page>
</template>

<script setup lang="ts">
import { IonPage, IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonList, IonItem, IonLabel } from '@ionic/vue';
import { Ricoh360Camera } from 'ricoh360-camera';
import { Filesystem } from '@capacitor/filesystem';
import { ref } from 'vue';
import { throttleTime, switchMap } from 'rxjs';

type PhotoEntry = {
  dateTimeZone: string;
  fileUrl: string;
  height: number;
  isProcessed: boolean;
  name: string;
  previewUrl: string;
  _projectionType: string;
  size: number;
  _thumbSize: number;
  width: number;
};

const photos = ref([] as PhotoEntry[]);
const showPreview = ref(false);
const previewImage = ref('');

async function downloadPhoto(photo: PhotoEntry) {
  const result = await Ricoh360Camera.getCameraAsset({ url: photo.fileUrl, saveToFile: true });
  console.log(result);
  const data = await Filesystem.readFile({ path: `file://${result.filePath!}` });
  console.log(typeof data.data === 'string' ? data.data.length : data.data.size);
}

async function listPhotos() {
  try {
    const result = await Ricoh360Camera.listFiles();
    if (typeof result === 'object' && typeof (result as any).results === 'object' && typeof (result as any).results.entries === 'object' && Array.isArray((result as any).results.entries)) {
      const entries = (result as any).results.entries as PhotoEntry[];
      // const downloadedPhotos = await Promise.all(entries.filter(entry => entry.fileUrl)
      //   .map(async (entry) => {
      //     const photo = await CapacitorHttp.get({
      //       url: entry.fileUrl,
      //       headers: {
      //         'Content-Type': 'application/octet-stream'
      //       }
      //     });
      //     return {
      //       download: photo,
      //       entry
      //     };
      //   }));
      photos.value = entries;
    } else {
      photos.value = [];
    }
  } catch (e) {
    console.error(e);
    // settingsValue.value = `Error: ${(e as any).message}`;
  }
}

async function openPhoto(photo: PhotoEntry) {
  console.log('Opening photo:', photo);
  const photoData = await Ricoh360Camera.getCameraAsset({ url: photo.fileUrl });
  const photoAsString = `data:image/jpeg;base64,${photoData.data}`;
  showPreview.value = true;

  setTimeout(() => {
    const divElement = document.getElementById('previewMagic-container-to-test');
    const getScene = async (id: string) => {
      console.log('getScene', photoAsString);
      return {
        id,
        image: {
          type: 'equirect',
          url: photoAsString,
          viewParams: { yaw: 0, pitch: 0, fov: 2.4 },
        }
      }
    };

    const eventHandler = {
      onSceneChange: (id: any) => {
        console.log(`Change scene: ${id}`);
      },
      onClick: (x: any) => console.log(`Click ${x}`),
      onTextureLoad: () => console.log('Texture loaded'),
      onViewChanged: (x: any) => {
        console.log(`View changed: ${JSON.stringify(x)}`);
      },
    };


    const { ViewerContainer } = (window as any).RICOH360Viewer as any;

    const viewer = new ViewerContainer({
      div: divElement,
      config: {
        color: {
          background: 'navy',
        },
        controls: {
          scrollZoom: true,
        },
        scene: {
          numOfCache: 3,
        },
        transitionDuration: 5, // millisecond
        view: {
          keepCoords: true,
          limit3D: {
            maxVFov: 2.8, // radian
            minVFov: 0.8,
            maxHFov: 2.8,
          },
        },
      },
      getScene,
      });
      viewer.viewerCreated$.subscribe(({ index }: { index: number }) =>
      console.log(`Viewer created: ${index}`),
      );
      viewer.viewerCreated$.subscribe(({ viewer: v, index }: { viewer: any, index: number }) => {
      v.sceneId$.subscribe(eventHandler.onSceneChange);
      v.viewCoords$
        .pipe(throttleTime(500))
        .subscribe(eventHandler.onViewChanged);
      v.clicked$.subscribe(eventHandler.onClick);
      v.clicked$
        .pipe(switchMap((x: any) => v.coordinatesToScreen(x)))
        .subscribe(console.log);
      v.textureLoaded$.subscribe(eventHandler.onTextureLoad);
      v.isActive$.subscribe((x: any) => console.log(`isActive: ${x}`));

      v.switchScene("sceneEqui");
    });

    viewer.addNewViewer();
  }, 100);
}
</script>

