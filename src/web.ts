import { WebPlugin } from '@capacitor/core';

import type { InitializeOptions, PictureCaptureOptions, VideoCaptureOptions, LivePreviewOptions, Ricoh360CameraPlugin, CommandResponse, CameraInfo } from './definitions';

export class Ricoh360CameraWeb extends WebPlugin implements Ricoh360CameraPlugin {
  async initialize(_options: InitializeOptions): Promise<CameraInfo> {
    throw new Error('Web implementation not available for initialize.');
  }

  async capturePicture(_options: PictureCaptureOptions): Promise<CommandResponse> {
    throw new Error('Web implementation not available for capturePicture.');
  }

  async captureVideo(_options: VideoCaptureOptions): Promise<CommandResponse> {
    throw new Error('Web implementation not available for captureVideo.');
  }

  async livePreview(_options: LivePreviewOptions): Promise<void> {
    throw new Error('Web implementation not available for livePreview.');
  }

  async stopLivePreview(): Promise<void> {
    throw new Error('Web implementation not available for stopLivePreview.');
  }

  async readSettings(): Promise<CommandResponse> {
    throw new Error('Web implementation not available for readSettings.');
  }

  async setSettings(_options: any): Promise<CommandResponse> {
    throw new Error('Web implementation not available for setSettings.');
  }
}
