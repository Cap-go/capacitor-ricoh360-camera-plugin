export interface InitializeOptions {
  url: string
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

export interface CameraSettings {
  iso?: number;
  shutterSpeed?: number;
}

export interface CommandResponse {
  session?: string;
  info?: string;
  preview?: string;
  picture?: string;
  settings?: string;
}

export interface Ricoh360CameraPlugin {
  /**
   * Initializes the SDK with camera URL
   */
  initialize(options: InitializeOptions): Promise<CommandResponse>

  /**
   * Captures a picture
   */
  capturePicture(): Promise<CommandResponse>

  /**
   * Captures a video
   */
  captureVideo(options: VideoCaptureOptions): Promise<CommandResponse>

  /**
   * Starts live preview
   */
  livePreview(options: LivePreviewOptions): Promise<CommandResponse>

  /**
   * Stops live preview
   */
  stopLivePreview(): Promise<CommandResponse>

  /**
   * Reads camera settings
   * @param options Array of option names to read from camera
   * @see https://github.com/ricohapi/theta-api-specs/tree/main/theta-web-api-v2.1/options
   */
  readSettings(options: { options: string[] }): Promise<CommandResponse>

  /**
   * Sets camera settings
   * @param options Object containing camera settings to set
   * @see https://github.com/ricohapi/theta-api-specs/tree/main/theta-web-api-v2.1/options
   */
  setSettings(options: { options: Record<string, any> }): Promise<CommandResponse>

  /**
   * Send raw command to camera
   * @param endpoint API endpoint (e.g. '/osc/commands/execute')
   * @param payload Raw JSON payload
   */
  sendCommand(options: { endpoint: string; payload: Record<string, any> }): Promise<CommandResponse>
}

// interface LivePreviewResult {
//   frame: string; // Base64 encoded JPEG frame
// }
