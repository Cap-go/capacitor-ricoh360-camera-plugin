import { WebPlugin } from '@capacitor/core';

import type { Ricoh360CameraPlugin, CommandResponse, GetCameraAssetOptions, GetCameraAssetResponse, ListFilesOptions, ListFilesResponse } from './definitions';

export class Ricoh360CameraWeb extends WebPlugin implements Ricoh360CameraPlugin {
  async initialize(__options: any): Promise<CommandResponse> {
    throw new Error('Web implementation not available for initialize.');
  }

  async getCameraAsset(options: GetCameraAssetOptions): Promise<GetCameraAssetResponse> {
    throw this.unimplemented('Not implemented on web.');
  }

  async listFiles(options: ListFilesOptions): Promise<ListFilesResponse> {
    throw this.unimplemented('Not implemented on web.');
  }

  async capturePicture(): Promise<CommandResponse> {
    throw new Error('Web implementation not available for capturePicture.');
  }

  async captureVideo(__options: any): Promise<CommandResponse> {
    throw new Error('Web implementation not available for captureVideo.');
  }

  async livePreview(_options: any): Promise<CommandResponse> {
    throw new Error('Web implementation not available for livePreview.');
  }

  async stopLivePreview(): Promise<CommandResponse> {
    throw new Error('Web implementation not available for stopLivePreview.');
  }

  async readSettings(_options: any): Promise<CommandResponse> {
    throw new Error('Web implementation not available for readSettings.');
  }

  async setSettings(_options: any): Promise<CommandResponse> {
    throw new Error('Web implementation not available for setSettings.');
  }

  async sendCommand(_options: any): Promise<CommandResponse> {
    throw new Error('Web implementation not available for sendCommand.');
  }
}
