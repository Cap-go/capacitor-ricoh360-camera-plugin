export interface InitializeOptions {
  cameraUrl: string,
  language?: 'en-US' | 'en-GB' | 'ja' | 'fr' | 'de' | 'zh-TW' | 'zh-CN' | 'it' | 'ko'
  setDateTime?: boolean,
  sleepDelay?: number,
  shutterSound?: number
}

export interface PictureCaptureOptions {
  // Define any specific options needed for capturing a picture
  fileFormat?: 'jpeg' | 'raw';
  exposureProgram?: number;
  iso?: number;
  shutterSpeed?: number;
}

export interface VideoCaptureOptions {
  // Define any specific options needed for capturing a video
  resolution?: '4K' | '2K';
  frameRate?: number;
  bitrate?: number;
}

export interface LivePreviewOptions {
  displayInFront?: boolean;
}

export interface CameraInfo {
  manufacturer: string;
  model: string;
  serialNumber: string;
  firmwareVersion: string;
  supportUrl: string;
  gps: boolean;
  gyro: boolean;
  uptime: number;
  api: string[];
  endpoints: {
    httpPort: number;
    httpUpdatesPort: number;
  };
  apiLevel: number[];
}

export interface CommandResponse {
  name: string;
  state: string;
  results?: any; // Use specific types if known
  error?: {
    code: string;
    message: string;
  };
}

export interface Ricoh360CameraPlugin {
  /**
   * Initializes the SDK 
   */
  initialize(options: InitializeOptions): Promise<CameraInfo>

  /**
   * Captures a picture
   */
  capturePicture(options: PictureCaptureOptions): Promise<CommandResponse>

  /**
   * Captures a video
   */
  captureVideo(options: VideoCaptureOptions): Promise<CommandResponse>

  /**
   * Starts live preview
   */
  livePreview(options: LivePreviewOptions): Promise<void>

  /**
   * Stops live preview
   */
  stopLivePreview(): Promise<void>

  /**
   * Reads camera settings
   */
  readSettings(): Promise<CommandResponse>

  /**
   * Sets camera settings
   */
  setSettings(options: any): Promise<CommandResponse>
}

// interface LivePreviewResult {
//   frame: string; // Base64 encoded JPEG frame
// }
