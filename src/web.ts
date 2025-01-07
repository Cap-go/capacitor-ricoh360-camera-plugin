import { WebPlugin } from '@capacitor/core';

import type { InitializeOptions, PictureCaptureOptions, Ricoh360CameraPlugin, VideoCaptureOptions } from './definitions';

export class Ricoh360CameraWeb extends WebPlugin implements Ricoh360CameraPlugin {
  livePreview(): Promise<void> {
    throw new Error('Method not implemented.');
  }
  stopLivePreview(): Promise<void> {
    throw new Error('Method not implemented.');
  }
  initialize(_options: InitializeOptions): Promise<void> {
    throw new Error('Method not implemented.');
  }
  capturePicture(_options: PictureCaptureOptions): Promise<void> {
    throw new Error('Method not implemented.');
  }
  captureVideo(_options: VideoCaptureOptions): Promise<void> {
    throw new Error('Method not implemented.');
  }
}
