export interface InitializeOptions {
  cameraUrl: string,
  language?: 'en-US' | 'en-GB' | 'ja' | 'fr' | 'de' | 'zh-TW' | 'zh-CN' | 'it' | 'ko'
  setDateTime?: boolean,
  sleepDelay?: number,
  shutterSound?: number
}

export interface PictureCaptureOptions {
  // to be implemented
}

export interface VideoCaptureOptions {
  // to be implemented
}

export interface Ricoh360CameraPlugin {
  /**
   * Initializes the SDK 
   */
  initialize(options: InitializeOptions): Promise<void>

  capturePicture(options: PictureCaptureOptions): Promise<void>

  captureVideo(options: VideoCaptureOptions): Promise<void>

  livePreview(): Promise<void>

  stopLivePreview(): Promise<void>
}

// interface LivePreviewResult {
//   frame: string; // Base64 encoded JPEG frame
// }