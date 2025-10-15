export interface InitializeOptions {
  url: string;
}

export interface GetCameraAssetOptions {
  url: string;
  saveToFile?: boolean;
}

export interface GetCameraAssetResponse {
  statusCode: number;
  data: string; // base64 encoded data
  filePath?: string;
}

export interface ListFilesOptions {
  fileType?: 'all' | 'image' | 'video';
  startPosition?: number;
  entryCount?: number;
  maxThumbSize?: number;
  _detail?: boolean;
}

export interface ListFilesResponse {
  results: {
    entries: {
      name: string;
      fileUrl: string;
      size: number;
      dateTimeZone: string;
      width?: number;
      height?: number;
      previewUrl?: string;
      _projectionType?: string;
      isProcessed?: boolean;
      _thumbSize?: number;
    }[];
    totalEntries: number;
  };
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
  cropPreview?: boolean;
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
  initialize(options: InitializeOptions): Promise<CommandResponse>;

  /**
   * Retrieves a camera asset from a URL and returns it as base64
   * @param options Object containing the URL to fetch the asset from
   * @returns Promise with the status code and base64-encoded data
   */
  getCameraAsset(options: GetCameraAssetOptions): Promise<GetCameraAssetResponse>;

  /**
   * Lists files stored on the camera
   * @param options Optional parameters to filter and paginate results
   * @returns Promise with the list of files and their metadata
   */
  listFiles(options?: ListFilesOptions): Promise<ListFilesResponse>;

  /**
   * Captures a picture
   */
  capturePicture(): Promise<CommandResponse>;

  /**
   * Captures a video
   */
  captureVideo(options: VideoCaptureOptions): Promise<CommandResponse>;

  /**
   * Starts live preview
   */
  livePreview(options: LivePreviewOptions): Promise<CommandResponse>;

  /**
   * Stops live preview
   */
  stopLivePreview(): Promise<CommandResponse>;

  /**
   * Reads camera settings
   * @param options Array of option names to read from camera
   * @see https://github.com/ricohapi/theta-api-specs/tree/main/theta-web-api-v2.1/options
   */
  readSettings(options: { options: string[] }): Promise<CommandResponse>;

  /**
   * Sets camera settings
   * @param options Object containing camera settings to set
   * @see https://github.com/ricohapi/theta-api-specs/tree/main/theta-web-api-v2.1/options
   */
  setSettings(options: { options: Record<string, any> }): Promise<CommandResponse>;

  /**
   * Send raw command to camera
   * @param endpoint API endpoint (e.g. '/osc/commands/execute')
   * @param payload Raw JSON payload
   */
  sendCommand(options: { endpoint: string; payload: Record<string, any> }): Promise<CommandResponse>;
}

// interface LivePreviewResult {
//   frame: string; // Base64 encoded JPEG frame
// }
