export interface InitializeOptions {
  cameraUrl: String
}

export interface PictureCaptureOptions {
  // to be implemented
}

export interface VideoCaptureOptions {
  // to be implemented
  language: string
}

export interface Ricoh360CameraPlugin {
  /**
   * Initializes the SDK 
   */
  initialize(options: InitializeOptions): Promise<void>

  capturePicture(options: PictureCaptureOptions): Promise<void>

  captureVideo(options: VideoCaptureOptions): Promise<void>
}